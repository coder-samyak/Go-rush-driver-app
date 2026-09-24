const mongoose = require('mongoose');

const rideSchema = new mongoose.Schema(
  {
    rideId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    driverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Driver',
      default: null,
      index: true,
    },
    // A requested ride is reserved for one driver before it is accepted.
    // This prevents every online device receiving the same demo offer.
    offeredToDriverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Driver',
      default: null,
      index: true,
    },
    passenger: {
      name: { type: String, required: true, default: 'Priya Sharma' },
      phone: { type: String, default: '+91 98765 43210' },
      rating: { type: Number, default: 4.8 },
      totalRides: { type: Number, default: 120 },
      avatar: { type: String, default: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150' },
      vehicleTier: { type: String, default: 'Prime Sedan' },
    },
    pickup: {
      address: { type: String, required: true, default: 'Sector 62, Noida' },
      area: { type: String, default: 'Sector 62' },
      lat: { type: Number, default: 28.6280 },
      lng: { type: Number, default: 77.3649 },
      distanceAway: { type: String, default: '2.1 km away' },
    },
    destination: {
      address: { type: String, required: true, default: 'Connaught Place, New Delhi' },
      area: { type: String, default: 'Connaught Place' },
      lat: { type: Number, default: 28.6328 },
      lng: { type: Number, default: 77.2197 },
    },
    status: {
      type: String,
      enum: ['requested', 'accepted', 'arrived', 'in_progress', 'completed', 'cancelled'],
      default: 'requested',
      index: true,
    },
    distanceKm: {
      type: Number,
      required: true,
      default: 16.4,
    },
    durationMin: {
      type: Number,
      required: true,
      default: 32,
    },
    otp: {
      type: String,
      required: true,
      default: '4892',
    },
    fare: {
      baseFare: { type: Number, default: 200 },
      distanceFare: { type: Number, default: 110 },
      taxes: { type: Number, default: 52 },
      total: { type: Number, default: 362 },
      driverEarnings: { type: Number, default: 310 },
      paymentMethod: { type: String, default: 'Cash / UPI' },
      isPaid: { type: Boolean, default: false },
    },
    requestedAt: {
      type: Date,
      default: Date.now,
    },
    acceptedAt: {
      type: Date,
      default: null,
    },
    arrivedAt: {
      type: Date,
      default: null,
    },
    startedAt: {
      type: Date,
      default: null,
    },
    completedAt: {
      type: Date,
      default: null,
    },
    cancelledAt: {
      type: Date,
      default: null,
    },
    cancellationReason: {
      type: String,
      default: null,
    },
    driverLocation: {
      lat: { type: Number, default: null },
      lng: { type: Number, default: null },
      accuracy: { type: Number, default: null },
      updatedAt: { type: Date, default: null },
    },
    cancelledBy: {
      type: String,
      enum: ['driver', 'passenger', 'system', null],
      default: null,
    },
  },
  {
    timestamps: true,
    collection: 'rides',
  }
);

// Method to format safe ride object
rideSchema.methods.toSafeObject = function () {
  const obj = this.toObject ? this.toObject() : { ...this };
  delete obj.__v;
  return obj;
};

const Ride = mongoose.model('Ride', rideSchema, 'rides');

module.exports = Ride;
