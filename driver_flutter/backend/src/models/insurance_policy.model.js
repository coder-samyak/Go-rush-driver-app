const mongoose = require('mongoose');

const policySchema = new mongoose.Schema({
  driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true, unique: true, index: true },
  policyCode: { type: String, required: true, trim: true },
  status: { type: String, enum: ['active', 'pending', 'expired', 'cancelled'], default: 'pending' },
  details: { type: mongoose.Schema.Types.Mixed, default: {} },
  enrolledAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, default: null },
}, { timestamps: true, collection: 'insurance_policies' });

module.exports = mongoose.model('InsurancePolicy', policySchema);
