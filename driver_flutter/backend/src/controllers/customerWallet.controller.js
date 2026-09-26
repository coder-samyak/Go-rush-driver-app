const CustomerWallet = require('../models/customer_wallet.model');

async function ensureWallet(customerId) {
  let wallet = await CustomerWallet.findOne({ customerId });
  if (!wallet) {
    wallet = await CustomerWallet.create({ customerId });
  }
  return wallet;
}

exports.getWallet = async (req, res) => {
  try {
    const wallet = await ensureWallet(req.customer._id);
    return res.status(200).json({
      walletBalanceMinor: wallet.balance,
      promoBalanceMinor: wallet.promoBalance,
      totalAvailableMinor: wallet.balance + wallet.promoBalance,
      formattedWalletBalance: `₹${(wallet.balance / 100).toFixed(2)}`,
      formattedPromoBalance: `₹${(wallet.promoBalance / 100).toFixed(2)}`,
      formattedTotalAvailable: `₹${((wallet.balance + wallet.promoBalance) / 100).toFixed(2)}`,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.addMoney = async (req, res) => {
  try {
    const amountMinor = Number(req.body.amountMinor);
    const wallet = await ensureWallet(req.customer._id);
    wallet.balance += amountMinor;
    await wallet.save();
    return res.status(200).json({ status: 'TOPUP_SUCCESSFUL' });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getTransactions = async (req, res) => {
  return res.status(200).json([]);
};

exports.getRefunds = async (req, res) => {
  return res.status(200).json([]);
};

exports.getPaymentMethods = async (req, res) => {
  return res.status(200).json([]);
};

exports.addPaymentMethod = async (req, res) => {
  return res.status(200).json({ id: 'pm_1', type: req.body.type, title: req.body.title, subtitle: req.body.subtitle, icon: 'credit_card', isDefault: true });
};

exports.setDefaultPaymentMethod = async (req, res) => {
  return res.status(200).json([]);
};

exports.deletePaymentMethod = async (req, res) => {
  return res.status(200).json({ success: true });
};

exports.getPromoCredits = async (req, res) => {
  return res.status(200).json([]);
};

exports.redeemPromo = async (req, res) => {
  return res.status(200).json({ status: 'PROMO_REDEEMED', addedCreditMinor: 10000 });
};
