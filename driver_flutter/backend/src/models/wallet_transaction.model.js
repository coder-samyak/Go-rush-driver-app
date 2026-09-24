const mongoose = require('mongoose');

/**
 * GoRush Wallet Transaction Ledger
 * Permanent immutable record of every credit and debit on a driver wallet.
 * idempotencyKey ensures the same operation is NEVER applied twice.
 */
const walletTransactionSchema = new mongoose.Schema(
  {
    driverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Driver',
      required: true,
      index: true,
    },
    rideId: {
      type: String,
      default: null,
      trim: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['CREDIT', 'DEBIT'],
      required: true,
    },
    category: {
      type: String,
      enum: ['COMPANY_CHARGE', 'RECHARGE', 'REVERSAL', 'PENALTY', 'BONUS'],
      required: true,
    },
    amount: {
      type: Number,
      required: true,
      min: [0.01, 'Transaction amount must be positive'],
    },
    balanceBefore: {
      type: Number,
      required: true,
    },
    balanceAfter: {
      type: Number,
      required: true,
    },
    paymentMethod: {
      type: String,
      default: null,
      trim: true,
    },
    description: {
      type: String,
      default: null,
      trim: true,
    },
    /**
     * Idempotency key prevents duplicate deductions.
     * For company charges: `${rideId}_COMPANY_CHARGE`
     * For recharges: `recharge_${driverId}_${timestamp}`
     * For reversals: `${rideId}_REVERSAL`
     */
    idempotencyKey: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    status: {
      type: String,
      enum: ['SUCCESS', 'FAILED', 'PENDING', 'REVERSED'],
      default: 'SUCCESS',
    },
    // Extra metadata for admin audit
    metadata: {
      companyChargePercent: { type: Number, default: null },
      rideFare: { type: Number, default: null },
      paymentGatewayRef: { type: String, default: null },
    },
  },
  {
    timestamps: true,
    collection: 'wallet_transactions',
  }
);

// Formatting helper for UI display
walletTransactionSchema.methods.toSafeObject = function () {
  return {
    _id: this._id,
    driverId: this.driverId,
    rideId: this.rideId,
    type: this.type,
    category: this.category,
    amount: this.amount,
    balanceBefore: this.balanceBefore,
    balanceAfter: this.balanceAfter,
    paymentMethod: this.paymentMethod,
    description: this.description,
    idempotencyKey: this.idempotencyKey,
    status: this.status,
    metadata: this.metadata,
    createdAt: this.createdAt,
  };
};

const WalletTransaction = mongoose.model(
  'WalletTransaction',
  walletTransactionSchema,
  'wallet_transactions'
);

module.exports = WalletTransaction;
