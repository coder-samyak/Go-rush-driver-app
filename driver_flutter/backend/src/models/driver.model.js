const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const driverSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Driver name is required'],
      trim: true,
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Email address is required'],
      unique: true,
      trim: true,
      lowercase: true,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Please enter a valid email address'],
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [4, 'Password/PIN must be at least 4 characters long'],
      select: false,
    },
    profileImage: {
      type: String,
      default: null,
      trim: true,
    },
    licenseNumber: {
      type: String,
      default: null,
      trim: true,
    },
    status: {
      type: String,
      enum: ['offline', 'online', 'busy', 'suspended', 'inactive'],
      default: 'offline',
    },
    // Updated by the driver's rating/review workflow. A missing rating is
    // intentionally represented as 0 so incentives never award demo credit.
    rating: {
      type: Number,
      min: 0,
      max: 5,
      default: 0,
    },
    vehicleId: {
      type: String,
      default: null,
      trim: true,
    },
    city: {
      type: String,
      default: null,
      trim: true,
    },
    address: {
      type: String,
      default: null,
      trim: true,
    },
    vehicles: [
      {
        model: { type: String, required: true, trim: true },
        regNumber: { type: String, required: true, trim: true },
        type: { type: String, default: 'Sedan', trim: true },
        isPrimary: { type: Boolean, default: false },
        isVerified: { type: Boolean, default: true },
        createdAt: { type: Date, default: Date.now },
      },
    ],
    privacySettings: {
      biometricLock: { type: Boolean, default: true },
      backgroundLocation: { type: Boolean, default: true },
      twoFactorAuth: { type: Boolean, default: true },
      maskPhoneNumber: { type: Boolean, default: true },
    },
    dateOfBirth: { type: Date, default: null },
    documents: {
      profilePhoto: { type: String, default: null },
      drivingLicense: { type: String, default: null },
      vehicleRc: { type: String, default: null },
      vehicleInsurance: { type: String, default: null },
      policeVerification: { type: String, default: null },
    },
    vehicleInsuranceDetails: {
      documentName: { type: String, default: null, trim: true },
      // Stored for the driver's insurance upload but deliberately excluded
      // from profile responses and normal queries.
      documentData: { type: String, default: null },
      policyNumber: { type: String, default: null, trim: true },
      insuranceCompany: { type: String, default: null, trim: true },
      coverageAmount: { type: String, default: 'Based on vehicle repair/damage assessment', trim: true },
      yearlyPackage: { type: String, default: null, trim: true },
      premiumAmount: { type: String, default: null, trim: true },
      startDate: { type: Date, default: null },
      expiryDate: { type: Date, default: null },
      status: {
        type: String,
        enum: ['Pending', 'Verified', 'Active', 'Expired'],
        default: 'Pending',
      },
      uploadedAt: { type: Date, default: null },
    },
    driverInsuranceDetails: {
      documentName: { type: String, default: null, trim: true },
      documentData: { type: String, default: null },
      policyNumber: { type: String, default: null, trim: true },
      insuranceCompany: { type: String, default: null, trim: true },
      coverageAmount: { type: String, default: '₹5,00,000', trim: true },
      yearlyPackage: { type: String, default: null, trim: true },
      premiumAmount: { type: String, default: null, trim: true },
      startDate: { type: Date, default: null },
      expiryDate: { type: Date, default: null },
      status: { type: String, enum: ['Pending', 'Verified', 'Active', 'Expired'], default: 'Pending' },
      uploadedAt: { type: Date, default: null },
    },
  },
  {
    timestamps: true,
    collection: 'drivers',
  }
);

// Hash password before saving if modified
driverSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

// Instance method to compare password during login
driverSchema.methods.matchPassword = async function (enteredPassword) {
  if (!this.password) return false;
  return bcrypt.compare(enteredPassword, this.password);
};

// Instance helper to serialize driver safely without password or __v
driverSchema.methods.toSafeObject = function () {
  const driverObj = this.toObject ? this.toObject() : { ...this };
  delete driverObj.password;
  delete driverObj.__v;
  return {
    _id: driverObj._id,
    name: driverObj.name,
    phone: driverObj.phone,
    email: driverObj.email,
    licenseNumber: driverObj.licenseNumber !== undefined ? driverObj.licenseNumber : null,
    profileImage: driverObj.profileImage !== undefined ? driverObj.profileImage : null,
    status: driverObj.status || 'offline',
    rating: typeof driverObj.rating === 'number' ? driverObj.rating : 0,
    vehicleId: driverObj.vehicleId !== undefined ? driverObj.vehicleId : null,
    city: driverObj.city !== undefined ? driverObj.city : null,
    address: driverObj.address !== undefined ? driverObj.address : null,
    vehicles: driverObj.vehicles || [],
    privacySettings: driverObj.privacySettings || {
      biometricLock: true,
      backgroundLocation: true,
      twoFactorAuth: true,
      maskPhoneNumber: true,
    },
    dateOfBirth: driverObj.dateOfBirth || null,
    documents: driverObj.documents || {},
    vehicleInsuranceDetails: (() => {
      const insurance = { ...(driverObj.vehicleInsuranceDetails || {}) };
      delete insurance.documentData;
      return insurance;
    })(),
    driverInsuranceDetails: (() => {
      const insurance = { ...(driverObj.driverInsuranceDetails || {}) };
      delete insurance.documentData;
      return insurance;
    })(),
    createdAt: driverObj.createdAt,
    updatedAt: driverObj.updatedAt,
  };
};

const Driver = mongoose.model('Driver', driverSchema, 'drivers');

module.exports = Driver;
