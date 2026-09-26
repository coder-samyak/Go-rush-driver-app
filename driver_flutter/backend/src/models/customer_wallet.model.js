const mongoose = require('mongoose');

const customerWalletSchema = new mongoose.Schema({
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true, unique: true },
  balance: { type: Number, default: 0 },
  promoBalance: { type: Number, default: 0 },
  currency: { type: String, default: 'INR' },
}, { timestamps: true });

customerWalletSchema.methods.toSafeObject = function() {
  return {
    customerId: this.customerId,
    balance: this.balance,
    promoBalance: this.promoBalance,
    currency: this.currency,
  };
};

module.exports = mongoose.model('CustomerWallet', customerWalletSchema);
