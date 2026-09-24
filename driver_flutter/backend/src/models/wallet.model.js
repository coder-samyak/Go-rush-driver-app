const mongoose = require('mongoose');

/**
 * GoRush Driver Wallet Model
 * One wallet per driver. Balance is always stored in INR paise-equivalent floats.
 * Wallet balance is NEVER modified directly by the driver — only via server-side logic.
 */
const walletSchema = new mongoose.Schema(
  {
    driverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Driver',
      required: [true, 'Driver ID is required'],
      unique: true,
      index: true,
    },
    balance: {
      type: Number,
      default: 0,
      min: [0, 'Wallet balance cannot be negative'],
    },
    minimumRequiredBalance: {
      type: Number,
      default: 100,
    },
    currency: {
      type: String,
      default: 'INR',
      trim: true,
    },
    isBlocked: {
      type: Boolean,
      default: false,
    },
    totalRecharged: {
      type: Number,
      default: 0,
    },
    totalCompanyChargesDeducted: {
      type: Number,
      default: 0,
    },
    lastTransactionAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
    collection: 'wallets',
  }
);

// Virtual: is the balance sufficient to accept rides?
walletSchema.virtual('isSufficient').get(function () {
  return this.balance >= this.minimumRequiredBalance;
});

// Safe serialization — never expose internal Mongo fields
walletSchema.methods.toSafeObject = function () {
  return {
    _id: this._id,
    driverId: this.driverId,
    balance: this.balance,
    minimumRequiredBalance: this.minimumRequiredBalance,
    currency: this.currency,
    isBlocked: this.isBlocked,
    isSufficient: this.balance >= this.minimumRequiredBalance,
    totalRecharged: this.totalRecharged,
    totalCompanyChargesDeducted: this.totalCompanyChargesDeducted,
    lastTransactionAt: this.lastTransactionAt,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt,
  };
};

const Wallet = mongoose.model('Wallet', walletSchema, 'wallets');

module.exports = Wallet;
