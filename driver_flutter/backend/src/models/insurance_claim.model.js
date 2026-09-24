const mongoose = require('mongoose');

const claimSchema = new mongoose.Schema({
  driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true, index: true },
  rideId: { type: mongoose.Schema.Types.ObjectId, ref: 'Ride', default: null, index: true },
  claimType: { type: String, required: true, trim: true, maxlength: 80 },
  incidentDate: { type: Date, default: null },
  incidentTime: { type: String, trim: true, maxlength: 40, default: null },
  incidentLocation: { type: String, trim: true, maxlength: 240, default: null },
  description: { type: String, required: true, trim: true, maxlength: 4000 },
  amount: { type: Number, min: 0, default: null },
  claimNumber: { type: String, trim: true, maxlength: 80, unique: true, sparse: true },
  status: { type: String, enum: ['submitted', 'under_review', 'approved', 'rejected', 'settled'], default: 'submitted', index: true },
  providerReference: { type: String, default: null, trim: true },
}, { timestamps: true, collection: 'insurance_claims' });

module.exports = mongoose.model('InsuranceClaim', claimSchema);
