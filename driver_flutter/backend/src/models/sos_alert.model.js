const mongoose = require('mongoose');

const sosAlertSchema = new mongoose.Schema({
  driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true, index: true },
  rideId: { type: String, default: null },
  location: {
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
    accuracy: { type: Number, default: null },
  },
  status: { type: String, enum: ['active', 'resolved'], default: 'active', index: true },
  triggeredAt: { type: Date, default: Date.now },
  resolvedAt: { type: Date, default: null },
}, { timestamps: true, collection: 'sos_alerts' });

module.exports = mongoose.model('SosAlert', sosAlertSchema);
