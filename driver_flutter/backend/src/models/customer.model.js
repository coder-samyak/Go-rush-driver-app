const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const customerSchema = new mongoose.Schema(
  {
    name: { type: String, trim: true, default: null },
    phone: { type: String, required: true, unique: true, trim: true, index: true },
    email: { type: String, unique: true, sparse: true, lowercase: true, trim: true },
    password: { type: String, select: false },
    otpHash: { type: String, select: false },
    otpExpiresAt: { type: Date, select: false },
    otpAttempts: { type: Number, default: 0, select: false },
    profileComplete: { type: Boolean, default: false },
    savedLocations: { type: [mongoose.Schema.Types.Mixed], default: [] },
    status: { type: String, enum: ['active', 'blocked'], default: 'active' },
  },
  { timestamps: true, collection: 'customers' }
);

customerSchema.pre('save', async function (next) {
  if (!this.isModified('password') || !this.password) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

customerSchema.methods.matchPassword = function (password) {
  return this.password ? bcrypt.compare(password, this.password) : false;
};

customerSchema.methods.toSafeObject = function () {
  const value = this.toObject();
  delete value.password;
  delete value.otpHash;
  delete value.otpExpiresAt;
  delete value.otpAttempts;
  delete value.__v;
  return value;
};

module.exports = mongoose.model('Customer', customerSchema, 'customers');
