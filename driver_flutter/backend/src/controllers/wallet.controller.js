const mongoose = require('mongoose');
const Wallet = require('../models/wallet.model');
const WalletTransaction = require('../models/wallet_transaction.model');
const PlatformConfig = require('../models/platform_config.model');

/**
 * Ensure a wallet exists for the given driverId.
 * Called automatically on first wallet API access and during ride acceptance.
 * Safe to call multiple times — idempotent.
 */
async function ensureWallet(driverId, minimumRequiredBalance = 100) {
  let wallet = await Wallet.findOne({ driverId });
  if (!wallet) {
    wallet = await Wallet.create({
      driverId,
      balance: 0,
      minimumRequiredBalance,
      currency: 'INR',
      isBlocked: false,
    });
  }
  return wallet;
}

/**
 * GET /api/driver/wallet
 * Returns the driver's wallet balance and status.
 */
exports.getWallet = async (req, res) => {
  try {
    const driverId = req.driver._id;
    const config = await PlatformConfig.getConfig();
    const wallet = await ensureWallet(driverId, config.minimumWalletBalance);

    return res.status(200).json({
      success: true,
      wallet: wallet.toSafeObject(),
      config: {
        companyChargeType: config.companyChargeType,
        companyChargeValue: config.companyChargeValue,
        minimumWalletBalance: config.minimumWalletBalance,
      },
    });
  } catch (err) {
    console.error('getWallet error:', err);
    return res.status(500).json({ success: false, message: 'Server error fetching wallet', error: err.message });
  }
};

/**
 * GET /api/driver/wallet/status
 * Quick check — is the driver's wallet sufficient to accept rides?
 */
exports.getWalletStatus = async (req, res) => {
  try {
    const driverId = req.driver._id;
    const config = await PlatformConfig.getConfig();
    const wallet = await ensureWallet(driverId, config.minimumWalletBalance);

    const isSufficient = wallet.balance >= config.minimumWalletBalance;

    return res.status(200).json({
      success: true,
      data: {
        balance: wallet.balance,
        minimumRequiredBalance: config.minimumWalletBalance,
        isSufficient,
        isBlocked: wallet.isBlocked,
        currency: wallet.currency,
      },
    });
  } catch (err) {
    console.error('getWalletStatus error:', err);
    return res.status(500).json({ success: false, message: 'Server error checking wallet status', error: err.message });
  }
};

/**
 * GET /api/driver/wallet/transactions
 * Returns the driver's full transaction ledger (most recent first).
 */
exports.getTransactions = async (req, res) => {
  try {
    const driverId = req.driver._id;
    const limit = Math.min(parseInt(req.query.limit) || 50, 100);
    const skip = parseInt(req.query.skip) || 0;

    const transactions = await WalletTransaction.find({ driverId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await WalletTransaction.countDocuments({ driverId });

    return res.status(200).json({
      success: true,
      data: {
        transactions: transactions.map((t) => t.toSafeObject()),
        total,
        limit,
        skip,
      },
    });
  } catch (err) {
    console.error('getTransactions error:', err);
    return res.status(500).json({ success: false, message: 'Server error fetching transactions', error: err.message });
  }
};

/**
 * POST /api/driver/wallet/recharge
 * Add money to the driver's wallet.
 *
 * In production this would verify a payment gateway callback.
 * For now we accept the amount and create a CREDIT transaction.
 * The server NEVER trusts amounts that bypass this endpoint.
 */
exports.recharge = async (req, res) => {
  try {
    const driverId = req.driver._id;
    const amount = parseFloat(req.body.amount);

    if (!amount || amount <= 0 || !Number.isFinite(amount)) {
      return res.status(400).json({ success: false, message: 'Invalid recharge amount. Must be a positive number.' });
    }

    if (amount > 100000) {
      return res.status(400).json({ success: false, message: 'Recharge amount cannot exceed ₹1,00,000 per transaction.' });
    }

    const config = await PlatformConfig.getConfig();
    const wallet = await ensureWallet(driverId, config.minimumWalletBalance);

    if (wallet.isBlocked) {
      return res.status(403).json({ success: false, message: 'Wallet is blocked. Please contact support.' });
    }

    // Idempotency key for recharge — uses timestamp to allow multiple recharges
    const idempotencyKey = `recharge_${driverId}_${Date.now()}`;

    const balanceBefore = wallet.balance;
    const balanceAfter = parseFloat((balanceBefore + amount).toFixed(2));

    // Atomic update using findOneAndUpdate
    const updatedWallet = await Wallet.findOneAndUpdate(
      { _id: wallet._id, driverId },
      {
        $set: {
          balance: balanceAfter,
          lastTransactionAt: new Date(),
        },
        $inc: { totalRecharged: amount },
      },
      { new: true, runValidators: true }
    );

    if (!updatedWallet) {
      return res.status(500).json({ success: false, message: 'Wallet update failed. Please try again.' });
    }

    // Record CREDIT transaction
    const txn = await WalletTransaction.create({
      driverId,
      rideId: null,
      type: 'CREDIT',
      category: 'RECHARGE',
      amount,
      balanceBefore,
      balanceAfter,
      paymentMethod: req.body.paymentMethod || 'UPI',
      description: `Wallet Recharge — ₹${amount.toFixed(0)}`,
      idempotencyKey,
      status: 'SUCCESS',
      metadata: { paymentGatewayRef: req.body.gatewayRef || null },
    });

    return res.status(200).json({
      success: true,
      message: `Wallet recharged successfully. New balance: ₹${balanceAfter}`,
      wallet: updatedWallet.toSafeObject(),
      transaction: txn.toSafeObject(),
    });
  } catch (err) {
    console.error('recharge error:', err);
    if (err.code === 11000) {
      return res.status(409).json({ success: false, message: 'Duplicate recharge request. Please wait and try again.' });
    }
    return res.status(500).json({ success: false, message: 'Server error processing recharge', error: err.message });
  }
};

/**
 * INTERNAL — processCompanyCharge
 * Called by ride.controller.js when a ride is completed.
 *
 * This is the core atomic wallet deduction function:
 * 1. Checks idempotency (same ride cannot be charged twice)
 * 2. Validates wallet has sufficient balance
 * 3. Atomically deducts balance using $inc
 * 4. Creates an immutable transaction record
 *
 * @param {ObjectId} driverId
 * @param {string} rideId - GoRush ride ID (e.g., GR-853948)
 * @param {number} rideFare - Total ride fare in INR
 * @param {string} paymentMethod - 'CASH', 'UPI', 'CARD' etc.
 * @returns {{ success, message, transaction, wallet }}
 */
exports.processCompanyCharge = async (driverId, rideId, rideFare, paymentMethod) => {
  const idempotencyKey = `${rideId}_COMPANY_CHARGE`;

  // Step 1: Idempotency check — prevent duplicate deductions
  const existing = await WalletTransaction.findOne({ idempotencyKey });
  if (existing) {
    console.log(`[Wallet] Company charge already processed for ride ${rideId}. Returning existing transaction.`);
    const wallet = await Wallet.findOne({ driverId });
    return {
      success: true,
      message: 'Company charge already processed (idempotent)',
      transaction: existing.toSafeObject(),
      wallet: wallet ? wallet.toSafeObject() : null,
      alreadyProcessed: true,
    };
  }

  // Step 2: Get platform config (admin-configurable charge rate)
  const config = await PlatformConfig.getConfig();
  const companyCharge = config.calculateCompanyCharge(rideFare);

  if (companyCharge <= 0) {
    return {
      success: true,
      message: 'No company charge applicable',
      transaction: null,
      wallet: null,
      companyCharge: 0,
    };
  }

  // Step 3: Ensure wallet exists
  const wallet = await ensureWallet(driverId, config.minimumWalletBalance);

  if (wallet.isBlocked) {
    return {
      success: false,
      message: 'WALLET_BLOCKED',
      error: 'Driver wallet is blocked. Cannot deduct company charge.',
    };
  }

  // Step 4: For CASH rides — check if balance is sufficient for company charge
  const isCash = paymentMethod && paymentMethod.toUpperCase().includes('CASH');
  if (isCash && wallet.balance < companyCharge) {
    return {
      success: false,
      message: 'INSUFFICIENT_WALLET_BALANCE',
      error: `Wallet balance ₹${wallet.balance} is less than company charge ₹${companyCharge}`,
      walletBalance: wallet.balance,
      companyCharge,
    };
  }

  // Step 5: Atomic balance deduction using findOneAndUpdate with $inc
  // This is safe against race conditions — MongoDB applies the delta atomically
  const balanceBefore = wallet.balance;
  const balanceAfter = parseFloat((balanceBefore - companyCharge).toFixed(2));

  const updatedWallet = await Wallet.findOneAndUpdate(
    { _id: wallet._id, driverId, balance: { $gte: companyCharge } },
    {
      $inc: {
        balance: -companyCharge,
        totalCompanyChargesDeducted: companyCharge,
      },
      $set: { lastTransactionAt: new Date() },
    },
    { new: true }
  );

  if (!updatedWallet) {
    return {
      success: false,
      message: 'INSUFFICIENT_WALLET_BALANCE',
      error: 'Wallet balance is insufficient for company charge deduction',
      walletBalance: wallet.balance,
      companyCharge,
    };
  }

  // Step 6: Create immutable transaction record
  let txn;
  try {
    txn = await WalletTransaction.create({
      driverId,
      rideId,
      type: 'DEBIT',
      category: 'COMPANY_CHARGE',
      amount: companyCharge,
      balanceBefore,
      balanceAfter,
      paymentMethod: paymentMethod || 'CASH',
      description: `Company Charge — Ride #${rideId}`,
      idempotencyKey,
      status: 'SUCCESS',
      metadata: {
        companyChargePercent: config.companyChargeValue,
        rideFare,
      },
    });
  } catch (txnErr) {
    // If transaction creation fails (e.g., race condition on idempotency key),
    // the wallet was already debited — roll back
    if (txnErr.code === 11000) {
      // Duplicate key — another process already created the transaction
      // Restore the wallet balance
      await Wallet.findOneAndUpdate(
        { _id: updatedWallet._id },
        { $inc: { balance: companyCharge, totalCompanyChargesDeducted: -companyCharge } }
      );
      const existingTxn = await WalletTransaction.findOne({ idempotencyKey });
      return {
        success: true,
        message: 'Company charge already processed (concurrent idempotent)',
        transaction: existingTxn ? existingTxn.toSafeObject() : null,
        wallet: updatedWallet.toSafeObject(),
        alreadyProcessed: true,
      };
    }
    throw txnErr;
  }

  console.log(`[Wallet] Company charge ₹${companyCharge} deducted from driver ${driverId} for ride ${rideId}. Balance: ₹${balanceBefore} → ₹${balanceAfter}`);

  return {
    success: true,
    message: `Company charge ₹${companyCharge} deducted successfully`,
    transaction: txn.toSafeObject(),
    wallet: updatedWallet.toSafeObject(),
    companyCharge,
    companyChargePercent: config.companyChargeValue,
    rideFare,
  };
};

/**
 * INTERNAL — checkWalletBalance
 * Used by ride acceptance to verify driver has enough balance.
 * Returns { allowed: bool, wallet, config, message }
 */
exports.checkWalletBalance = async (driverId) => {
  const config = await PlatformConfig.getConfig();
  if (!config.walletEnabled || !config.walletCheckOnAccept) {
    return { allowed: true, reason: 'wallet_check_disabled' };
  }

  const wallet = await ensureWallet(driverId, config.minimumWalletBalance);

  if (wallet.isBlocked) {
    return {
      allowed: false,
      reason: 'WALLET_BLOCKED',
      wallet: wallet.toSafeObject(),
      config,
    };
  }

  const isSufficient = wallet.balance >= config.minimumWalletBalance;
  return {
    allowed: isSufficient,
    reason: isSufficient ? 'OK' : 'LOW_WALLET_BALANCE',
    wallet: wallet.toSafeObject(),
    config,
  };
};

/**
 * GET /api/driver/wallet/config
 * Returns platform config for the app (company charge rate, minimum balance)
 */
exports.getPlatformConfig = async (req, res) => {
  try {
    const config = await PlatformConfig.getConfig();
    return res.status(200).json({
      success: true,
      data: {
        companyChargeType: config.companyChargeType,
        companyChargeValue: config.companyChargeValue,
        minimumWalletBalance: config.minimumWalletBalance,
        walletEnabled: config.walletEnabled,
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Server error fetching config', error: err.message });
  }
};

module.exports.ensureWallet = ensureWallet;
