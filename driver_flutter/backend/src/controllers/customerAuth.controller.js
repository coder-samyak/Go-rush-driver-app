const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const Customer = require('../models/customer.model');
const config = require('../config/env');

const tokenFor = (customer) => jwt.sign(
  { id: customer._id, phone: customer.phone, role: 'customer' },
  config.jwt.secret,
  { expiresIn: config.jwt.expiresIn || '7d' }
);

const normalizePhone = (phone) => String(phone || '').replace(/[^\d+]/g, '').trim();

exports.sendOtp = async (req, res) => {
  const phone = normalizePhone(req.body.phoneNumber);
  if (!phone) return res.status(400).json({ success: false, message: 'Phone number is required.' });
  const otp = process.env.NODE_ENV === 'production' ? null : (process.env.DEV_OTP || '123456');
  const customer = await Customer.findOneAndUpdate(
    { phone },
    { $setOnInsert: { phone }, $set: { otpHash: otp ? crypto.createHash('sha256').update(otp).digest('hex') : null, otpExpiresAt: new Date(Date.now() + 5 * 60 * 1000), otpAttempts: 0 } },
    { new: true, upsert: true }
  );
  // Production SMS delivery is intentionally provider-configured; never expose OTP there.
  return res.status(200).json({
    success: true,
    message: 'OTP sent successfully.',
    ...(process.env.NODE_ENV === 'production' ? {} : { devOtp: otp, customerId: customer._id }),
  });
};

exports.verifyOtp = async (req, res) => {
  const phone = normalizePhone(req.body.phoneNumber);
  const otp = String(req.body.otp || '');
  const customer = await Customer.findOne({ phone }).select('+otpHash +otpExpiresAt +otpAttempts');
  if (!customer || !customer.otpHash || !customer.otpExpiresAt || customer.otpExpiresAt < new Date() || customer.otpAttempts >= 5) {
    return res.status(401).json({ success: false, message: 'OTP expired or unavailable.' });
  }
  customer.otpAttempts += 1;
  if (crypto.createHash('sha256').update(otp).digest('hex') !== customer.otpHash) {
    await customer.save();
    return res.status(401).json({ success: false, message: 'Invalid OTP.' });
  }
  customer.otpHash = undefined;
  customer.otpExpiresAt = undefined;
  customer.otpAttempts = 0;
  await customer.save();
  return res.status(200).json({ success: true, user: customer.toSafeObject(), session: { accessToken: tokenFor(customer), refreshToken: null, expiresAt: new Date(Date.now() + 7 * 86400000).toISOString() } });
};

exports.register = async (req, res) => {
  const { name, email, phoneNumber, password } = req.body;
  const phone = normalizePhone(phoneNumber);
  if (!name || !phone || !password) return res.status(400).json({ success: false, message: 'Name, phone number, and password are required.' });
  if (String(password).length < 4) return res.status(400).json({ success: false, message: 'Password must be at least 4 characters.' });
  let customer = await Customer.findOne({ $or: [{ phone }, ...(email ? [{ email: email.toLowerCase().trim() }] : [])] }).select('+password');
  if (customer) {
    customer.name = name.trim();
    customer.email = email ? email.toLowerCase().trim() : customer.email;
    customer.password = password;
  } else {
    customer = new Customer({ name: name.trim(), email: email ? email.toLowerCase().trim() : undefined, phone, password, profileComplete: true });
  }
  await customer.save();
  return res.status(200).json({ success: true, user: customer.toSafeObject(), session: { accessToken: tokenFor(customer), refreshToken: null, expiresAt: new Date(Date.now() + 7 * 86400000).toISOString() } });
};

exports.login = async (req, res) => {
  const identifier = String(req.body.identifier || '').trim();
  const customer = await Customer.findOne({ $or: [{ phone: normalizePhone(identifier) }, { email: identifier.toLowerCase() }] }).select('+password');
  if (!customer || !(await customer.matchPassword(String(req.body.password || '')))) return res.status(401).json({ success: false, message: 'Invalid email/phone or password.' });
  return res.status(200).json({ success: true, user: customer.toSafeObject(), session: { accessToken: tokenFor(customer), refreshToken: null, expiresAt: new Date(Date.now() + 7 * 86400000).toISOString() } });
};

exports.me = async (req, res) => res.status(200).json({ success: true, user: req.customer.toSafeObject() });
