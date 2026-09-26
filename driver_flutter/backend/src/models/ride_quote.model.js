const mongoose = require('mongoose');

const quoteSchema = new mongoose.Schema(
  {
    quoteId: { type: String, required: true, unique: true, index: true },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true, index: true },
    distanceMeters: { type: Number, required: true, min: 1 },
    durationSeconds: { type: Number, required: true, min: 1 },
    rideCategory: { type: String, required: true, default: 'CAB' },
    total: { type: Number, required: true, min: 0 },
    expiresAt: { type: Date, required: true, index: { expires: 0 } },
  },
  { timestamps: true, collection: 'ride_quotes' }
);

module.exports = mongoose.model('RideQuote', quoteSchema, 'ride_quotes');
