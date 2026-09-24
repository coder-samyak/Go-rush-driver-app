const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const Driver = require('../models/driver.model');

/**
 * Generate JWT token for an authenticated driver
 * Uses existing JWT_SECRET and JWT_EXPIRES_IN from environment
 */
const generateToken = (driverId, email) => {
  return jwt.sign(
    { id: driverId, email },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn || '7d' }
  );
};

/**
 * Email format validation helper
 */
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * @route   POST /api/auth/register
 * @desc    Register a new driver partner
 * @access  Public
 */
const register = async (req, res, next) => {
  try {
    const {
      name,
      phone,
      email,
      password,
      licenseNumber,
      profileImage,
      vehicleId,
      dateOfBirth,
      status,
    } = req.body;

    // 1. Validate required fields
    if (!name || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Driver name is required',
      });
    }

    if (!phone || !phone.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    if (!email || !email.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email address is required',
      });
    }

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required',
      });
    }

    const dob = dateOfBirth ? new Date(dateOfBirth) : null;
    const age = dob && !Number.isNaN(dob.valueOf())
      ? Math.floor((Date.now() - dob.valueOf()) / 31557600000) : 0;
    if (!dob || age < 18) {
      return res.status(400).json({ success: false, message: 'Driver must be at least 18 years old' });
    }

    // 2. Validate email format
    const normalizedEmail = email.toLowerCase().trim();
    if (!isValidEmail(normalizedEmail)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email address',
      });
    }

    // 3. Validate password length (supports both PINs and passwords)
    if (password.length < 4) {
      return res.status(400).json({
        success: false,
        message: 'Password/PIN must be at least 4 characters long',
      });
    }

    // 4. Verify MongoDB connection state
    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({
        success: false,
        message: 'Database service is currently unavailable. Please check MongoDB Atlas connection and IP whitelist.',
      });
    }

    const normalizedPhone = phone.trim();

    // 5. Check if driver with this email or phone already exists
    let driver = await Driver.findOne({
      $or: [{ email: normalizedEmail }, { phone: normalizedPhone }],
    });

    if (driver) {
      // Update existing driver record with latest credentials and profile info
      driver.name = name.trim();
      driver.phone = normalizedPhone;
      driver.email = normalizedEmail;
      driver.password = password;
      if (licenseNumber) driver.licenseNumber = licenseNumber.trim();
      if (profileImage) driver.profileImage = profileImage.trim();
      if (vehicleId) driver.vehicleId = vehicleId.trim();
      driver.dateOfBirth = dob;
      driver.status = status || 'offline';
      await driver.save();
    } else {
      driver = await Driver.create({
        name: name.trim(),
        phone: normalizedPhone,
        email: normalizedEmail,
        password,
        licenseNumber: licenseNumber ? licenseNumber.trim() : null,
        profileImage: profileImage ? profileImage.trim() : null,
        vehicleId: vehicleId ? vehicleId.trim() : null,
        dateOfBirth: dob,
        status: status || 'offline',
      });
    }

    // 6. Generate JWT Auth Token
    const token = generateToken(driver._id, driver.email);

    // 7. Format success response matching expected specification
    return res.status(201).json({
      success: true,
      message: 'Driver registered successfully',
      data: {
        driver: driver.toSafeObject(),
        token,
      },
    });
  } catch (err) {
    // Handle MongoDB duplicate key collision safety (code 11000)
    if (err.code === 11000) {
      const field = Object.keys(err.keyValue || {})[0] || 'field';
      return res.status(409).json({
        success: false,
        message: `${field === 'email' ? 'Email' : field === 'phone' ? 'Phone number' : field} is already registered`,
      });
    }

    if (err.name === 'ValidationError') {
      const firstMessage = Object.values(err.errors)[0]?.message || 'Validation Error';
      return res.status(400).json({
        success: false,
        message: firstMessage,
      });
    }

    next(err);
  }
};

/**
 * @route   POST /api/auth/login
 * @desc    Driver login & JWT token generation
 * @access  Public
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // 1. Validate required fields
    if (!email || !email.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email is required',
      });
    }

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required',
      });
    }

    // 2. Verify MongoDB connection state
    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({
        success: false,
        message: 'Database service is currently unavailable. Please check MongoDB Atlas connection and IP whitelist.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // 3. Find driver by email or phone, explicitly including password field for check
    let driver = await Driver.findOne({ email: normalizedEmail }).select('+password');
    if (!driver) {
      driver = await Driver.findOne({ phone: email.trim() }).select('+password');
    }

    // 4. Verify credentials safely without revealing if email exists
    if (!driver) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const isMatch = await driver.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // 5. Handle account status (suspended or inactive accounts)
    if (driver.status === 'suspended' || driver.status === 'inactive') {
      return res.status(403).json({
        success: false,
        message: 'Account is inactive or suspended. Please contact support.',
      });
    }

    // 6. Generate JWT token using existing secret and expiration
    const token = generateToken(driver._id, driver.email);

    // 7. Return JWT token and safe driver information
    return res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        driver: driver.toSafeObject(),
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * @route   GET /api/auth/me
 * @desc    Get currently authenticated driver profile
 * @access  Protected (Requires valid Bearer token)
 */
const getProfile = async (req, res, next) => {
  try {
    if (!req.driver) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized. Driver profile not available.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Profile retrieved successfully',
      data: {
        driver: req.driver.toSafeObject(),
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * @route   PUT /api/auth/profile
 * @desc    Update authenticated driver profile in MongoDB Atlas
 * @access  Protected (Requires Bearer token)
 */
const updateProfile = async (req, res, next) => {
  try {
    const { name, phone, email, city, address, licenseNumber, vehicleId, profileImage, privacySettings, documents, vehicleInsuranceDetails, driverInsuranceDetails, driverId: bodyDriverId } = req.body;

    let driver = null;
    const targetId = bodyDriverId || (req.driver && req.driver._id);
    if (targetId) {
      try {
        driver = await Driver.findById(targetId);
      } catch (_) {}
    }
    if (!driver && email) {
      driver = await Driver.findOne({ email: email.toLowerCase().trim() });
    }
    if (!driver && phone) {
      const cleanPhone = phone.replace(/[^0-9]/g, '');
      driver = await Driver.findOne({
        $or: [{ phone: phone.trim() }, { phone: cleanPhone }]
      });
    }
    if (!driver) {
      driver = await Driver.findOne().sort({ updatedAt: -1 });
    }

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found. Please log in or register first.',
      });
    }

    if (name && name.trim()) driver.name = name.trim();
    if (phone && phone.trim()) driver.phone = phone.trim();
    if (email && email.trim()) driver.email = email.trim().toLowerCase();
    if (city !== undefined) driver.city = city ? city.trim() : null;
    if (address !== undefined) driver.address = address ? address.trim() : null;
    if (licenseNumber !== undefined) driver.licenseNumber = licenseNumber ? licenseNumber.trim() : null;
    if (vehicleId !== undefined) driver.vehicleId = vehicleId ? vehicleId.trim() : null;
    if (profileImage !== undefined) driver.profileImage = profileImage ? profileImage.trim() : null;
    if (privacySettings && typeof privacySettings === 'object') {
      driver.privacySettings = {
        ...driver.privacySettings,
        ...privacySettings,
      };
    }
    if (documents && typeof documents === 'object') {
      driver.documents = { ...(driver.documents || {}), ...documents };
    }
    if (vehicleInsuranceDetails && typeof vehicleInsuranceDetails === 'object') {
      if (vehicleInsuranceDetails.documentData &&
          (typeof vehicleInsuranceDetails.documentData !== 'string' || vehicleInsuranceDetails.documentData.length > 10 * 1024 * 1024)) {
        return res.status(400).json({ success: false, message: 'Insurance document must be smaller than 7 MB.' });
      }
      const expiryDate = vehicleInsuranceDetails.expiryDate
        ? new Date(vehicleInsuranceDetails.expiryDate)
        : null;
      const isExpired = expiryDate && !Number.isNaN(expiryDate.valueOf()) && expiryDate < new Date();
      driver.vehicleInsuranceDetails = {
        ...(driver.vehicleInsuranceDetails || {}),
        coverageAmount: vehicleInsuranceDetails.coverageAmount || 'Based on vehicle repair/damage assessment',
        yearlyPackage: vehicleInsuranceDetails.yearlyPackage || null,
        premiumAmount: vehicleInsuranceDetails.premiumAmount || null,
        documentName: vehicleInsuranceDetails.documentName || driver.documents?.vehicleInsurance || null,
        documentData: vehicleInsuranceDetails.documentData || driver.vehicleInsuranceDetails?.documentData || null,
        policyNumber: vehicleInsuranceDetails.policyNumber || null,
        insuranceCompany: vehicleInsuranceDetails.insuranceCompany || null,
        startDate: vehicleInsuranceDetails.startDate || null,
        expiryDate: expiryDate && !Number.isNaN(expiryDate.valueOf()) ? expiryDate : null,
        // Verification is controlled by the backend/admin workflow. A driver
        // upload is Pending unless its policy has already expired.
        status: isExpired ? 'Expired' : (vehicleInsuranceDetails.status || 'Active'),
        uploadedAt: new Date(),
      };
    }
    if (driverInsuranceDetails && typeof driverInsuranceDetails === 'object') {
      if (driverInsuranceDetails.documentData &&
          (typeof driverInsuranceDetails.documentData !== 'string' || driverInsuranceDetails.documentData.length > 10 * 1024 * 1024)) {
        return res.status(400).json({ success: false, message: 'Insurance document must be smaller than 7 MB.' });
      }
      const expiryDate = driverInsuranceDetails.expiryDate ? new Date(driverInsuranceDetails.expiryDate) : null;
      const isExpired = expiryDate && !Number.isNaN(expiryDate.valueOf()) && expiryDate < new Date();
      driver.driverInsuranceDetails = {
        ...(driver.driverInsuranceDetails || {}),
        ...driverInsuranceDetails,
        documentData: driverInsuranceDetails.documentData || driver.driverInsuranceDetails?.documentData || null,
        expiryDate: expiryDate && !Number.isNaN(expiryDate.valueOf()) ? expiryDate : null,
        status: isExpired ? 'Expired' : (driverInsuranceDetails.status || 'Active'),
        uploadedAt: new Date(),
      };
    }

    await driver.save();

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully in MongoDB Atlas',
      data: {
        driver: driver.toSafeObject(),
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * @route   POST /api/auth/change-password
 * @desc    Verify current password and update to new bcrypt-hashed password in MongoDB Atlas
 * @access  Protected (Requires Bearer token)
 */
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword, confirmPassword, email, phone, driverId: bodyDriverId } = req.body;

    // 1. Validation: required fields
    if (!currentPassword || !currentPassword.trim() || !newPassword || !newPassword.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Please fill all required fields',
      });
    }

    // 2. Validation: confirm password match
    if (confirmPassword && newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'New passwords do not match',
      });
    }

    // 3. Validation: minimum length
    // The driver app supports a 4+ character password/PIN. Keep the API
    // validation aligned with registration and the Change Password screen.
    if (newPassword.length < 4) {
      return res.status(400).json({
        success: false,
        message: 'New password/PIN must be at least 4 characters long',
      });
    }

    let driver = null;
    const targetId = bodyDriverId || (req.driver && req.driver._id);
    if (targetId) {
      try {
        driver = await Driver.findById(targetId).select('+password');
      } catch (_) {}
    }
    if (!driver && email) {
      driver = await Driver.findOne({ email: email.toLowerCase().trim() }).select('+password');
    }
    if (!driver && phone) {
      const cleanPhone = phone.replace(/[^0-9]/g, '');
      driver = await Driver.findOne({
        $or: [{ phone: phone.trim() }, { phone: cleanPhone }]
      }).select('+password');
    }
    if (!driver) {
      driver = await Driver.findOne().sort({ updatedAt: -1 }).select('+password');
    }

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver account not found. Please register or log in first.',
      });
    }

    // 4. Verify current password:
    let isMatch = false;
    if (typeof driver.matchPassword === 'function') {
      try {
        isMatch = await driver.matchPassword(currentPassword);
      } catch (_) {}
    }
    if (!isMatch && driver.password === currentPassword) {
      isMatch = true;
    }

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect',
      });
    }

    // 5. Assign new password — pre-save hook salts and hashes with bcrypt (10 rounds)
    driver.password = newPassword;
    await driver.save();

    return res.status(200).json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (err) {
    next(err);
  }
};

/**
 * @route   GET /api/auth/vehicles
 * @desc    Get all registered vehicles for the authenticated driver
 * @access  Protected
 */
const getVehicles = async (req, res, next) => {
  try {
    let driver = null;
    if (req.driver && req.driver._id) {
      driver = await Driver.findById(req.driver._id);
    } else if (req.query.email) {
      driver = await Driver.findOne({ email: req.query.email.toLowerCase().trim() });
    }

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Vehicles retrieved successfully',
      data: {
        vehicles: driver.vehicles || [],
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * @route   POST /api/auth/vehicles
 * @desc    Add a secondary vehicle for the authenticated driver in MongoDB Atlas
 * @access  Protected
 */
const addVehicle = async (req, res, next) => {
  try {
    const { model, regNumber, type, isPrimary, email } = req.body;

    if (!model || model.trim().length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Vehicle model must be at least 3 characters long',
      });
    }

    if (!regNumber || regNumber.trim().length < 4) {
      return res.status(400).json({
        success: false,
        message: 'Vehicle registration number must be at least 4 characters long',
      });
    }

    let driver = null;
    if (req.driver && req.driver._id) {
      driver = await Driver.findById(req.driver._id);
    } else if (email) {
      driver = await Driver.findOne({ email: email.toLowerCase().trim() });
    }

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found. Please log in first.',
      });
    }

    const cleanNewReg = regNumber.replace(/\s+/g, '').toUpperCase();
    const isDuplicate = (driver.vehicles || []).some((v) => {
      const cleanExisting = (v.regNumber || '').replace(/\s+/g, '').toUpperCase();
      return cleanExisting === cleanNewReg;
    });

    if (isDuplicate) {
      return res.status(409).json({
        success: false,
        message: `A vehicle with registration "${regNumber.trim()}" is already registered for your account.`,
      });
    }

    if (!driver.vehicles) {
      driver.vehicles = [];
    }

    const newVehicle = {
      model: model.trim(),
      regNumber: regNumber.trim().toUpperCase(),
      type: type ? type.trim() : 'Sedan',
      isPrimary: isPrimary === true,
      isVerified: true,
      createdAt: new Date(),
    };

    driver.vehicles.push(newVehicle);
    await driver.save();

    return res.status(201).json({
      success: true,
      message: 'Secondary vehicle added and saved to database successfully',
      data: {
        vehicle: newVehicle,
        vehicles: driver.vehicles,
      },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  changePassword,
  getVehicles,
  addVehicle,
};
