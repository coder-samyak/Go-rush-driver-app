const mongoose = require('mongoose');

/**
 * Platform Configuration
 * Admin-configurable settings stored in MongoDB.
 * The mobile app NEVER receives commission values from the client side —
 * they are always fetched from this collection on the backend.
 *
 * Only one document exists (singleton pattern via `key: 'global'`).
 */
const platformConfigSchema = new mongoose.Schema(
  {
    key: {
      type: String,
      default: 'global',
      unique: true,
      index: true,
    },
    // Company charge settings
    companyChargeType: {
      type: String,
      enum: ['PERCENTAGE', 'FIXED'],
      default: 'PERCENTAGE',
    },
    companyChargeValue: {
      type: Number,
      default: 20, // 20% of ride fare
      min: 0,
    },
    // Wallet minimum balance requirement
    minimumWalletBalance: {
      type: Number,
      default: 100, // ₹100
      min: 0,
    },
    // Feature flags
    walletEnabled: {
      type: Boolean,
      default: true,
    },
    walletCheckOnAccept: {
      type: Boolean,
      default: true,
    },
    // Admin metadata
    lastUpdatedBy: {
      type: String,
      default: 'system',
    },
    notes: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
    collection: 'platform_configs',
  }
);

platformConfigSchema.statics.getConfig = async function () {
  let config = await this.findOne({ key: 'global' });
  if (!config) {
    // Auto-seed defaults on first access
    config = await this.create({ key: 'global' });
  }
  return config;
};

/**
 * Calculate company charge amount for a given fare.
 * Always uses server-side config — never trusts client values.
 */
platformConfigSchema.methods.calculateCompanyCharge = function (rideFare) {
  if (!rideFare || rideFare <= 0) return 0;
  if (this.companyChargeType === 'FIXED') {
    return this.companyChargeValue;
  }
  // PERCENTAGE
  return parseFloat(((rideFare * this.companyChargeValue) / 100).toFixed(2));
};

const PlatformConfig = mongoose.model(
  'PlatformConfig',
  platformConfigSchema,
  'platform_configs'
);

module.exports = PlatformConfig;
