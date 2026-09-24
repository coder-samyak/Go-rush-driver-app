const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
  driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true, index: true },
  claimId: { type: mongoose.Schema.Types.ObjectId, ref: 'InsuranceClaim', required: true, index: true },
  fileName: { type: String, required: true, trim: true, maxlength: 180 },
  mimeType: { type: String, required: true, enum: ['image/jpeg', 'image/png', 'application/pdf'] },
  size: { type: Number, required: true, min: 1, max: 5 * 1024 * 1024 },
  data: { type: Buffer, required: true, select: false },
}, { timestamps: true, collection: 'insurance_documents' });

module.exports = mongoose.model('InsuranceDocument', documentSchema);
