const mongoose = require('mongoose');
const InsurancePolicy = require('../models/insurance_policy.model');
const InsuranceClaim = require('../models/insurance_claim.model');
const InsuranceDocument = require('../models/insurance_document.model');
const Ride = require('../models/ride.model');
const { MockInsuranceProvider } = require('../services/insurance.provider');

const provider = new MockInsuranceProvider();
const id = value => mongoose.isValidObjectId(value);
const fail = (res, status, message) => res.status(status).json({ success: false, message });
const own = (query, driverId) => query.findOne({ _id: query._id, driverId });

exports.policy = async (req, res, next) => {
  try { return res.json({ success: true, data: await provider.getApprovedPolicy() }); } catch (e) { return next(e); }
};

exports.myPolicy = async (req, res, next) => {
  try {
    const policy = await InsurancePolicy.findOne({ driverId: req.driver._id }).lean();
    return res.json({ success: true, data: policy || null, message: policy ? undefined : 'No insurance policy enrolled.' });
  } catch (e) { return next(e); }
};

exports.enroll = async (req, res, next) => {
  try {
    const approved = await provider.getApprovedPolicy();
    const policyCode = String(req.body.policyCode || approved.code || 'approved-policy').trim();
    if (!policyCode || policyCode.length > 100) return fail(res, 400, 'A valid policy code is required.');
    const policy = await InsurancePolicy.findOneAndUpdate(
      { driverId: req.driver._id },
      { $set: { policyCode, details: approved, status: 'pending' }, $setOnInsert: { driverId: req.driver._id, enrolledAt: new Date() } },
      { new: true, upsert: true, runValidators: true }
    );
    return res.status(201).json({ success: true, data: policy });
  } catch (e) { return next(e); }
};

exports.ridePolicy = async (req, res, next) => {
  try {
    const rideQuery = id(req.params.rideId)
      ? { $or: [{ _id: req.params.rideId }, { rideId: req.params.rideId }], driverId: req.driver._id }
      : { rideId: req.params.rideId, driverId: req.driver._id };
    const ride = await Ride.findOne(rideQuery).lean();
    if (!ride) return fail(res, 404, 'Ride not found.');
    const policy = await InsurancePolicy.findOne({ driverId: req.driver._id }).lean();
    return res.json({ success: true, data: { rideId: ride._id, policy: policy || null } });
  } catch (e) { return next(e); }
};

exports.createClaim = async (req, res, next) => {
  try {
    const { claimType, description, amount, rideId, incidentLocation, incidentDate, incidentTime } = req.body || {};
    if (!claimType || typeof claimType !== 'string' || !rideId || typeof rideId !== 'string' ||
        !incidentLocation || typeof incidentLocation !== 'string' ||
        !description || typeof description !== 'string') {
      return fail(res, 400, 'Incident type, ride ID, incident location and description are required.');
    }
    if (claimType.trim().length > 80 || incidentLocation.trim().length > 240 || description.trim().length > 4000) {
      return fail(res, 400, 'Claim details exceed the allowed length.');
    }
    if (amount !== undefined && amount !== null && (!Number.isFinite(Number(amount)) || Number(amount) < 0)) return fail(res, 400, 'Amount must be a non-negative number.');
    if (incidentDate && Number.isNaN(Date.parse(incidentDate))) return fail(res, 400, 'Incident date is invalid.');
    let ride = null;
    if (rideId) {
      const rideQuery = id(rideId)
        ? { $or: [{ _id: rideId }, { rideId }], driverId: req.driver._id }
        : { rideId, driverId: req.driver._id };
      ride = await Ride.findOne(rideQuery);
      if (!ride) return fail(res, 404, 'Ride not found.');
    }
    const claim = await InsuranceClaim.create({
      driverId: req.driver._id,
      rideId: ride._id,
      claimType: claimType.trim(),
      incidentDate: incidentDate ? new Date(incidentDate) : new Date(),
      incidentTime: typeof incidentTime === 'string' ? incidentTime.trim() : null,
      incidentLocation: incidentLocation.trim(),
      description: description.trim(),
      amount: amount == null ? null : Number(amount),
    });
    const result = await provider.submitClaim(claim);
    claim.providerReference = result.reference;
    claim.claimNumber = result.reference;
    await claim.save();
    return res.status(201).json({ success: true, data: claim });
  } catch (e) { return next(e); }
};

exports.listClaims = async (req, res, next) => {
  try { return res.json({ success: true, data: await InsuranceClaim.find({ driverId: req.driver._id }).sort({ createdAt: -1 }).lean() }); } catch (e) { return next(e); }
};

exports.getClaim = async (req, res, next) => {
  try {
    if (!id(req.params.id)) return fail(res, 400, 'Invalid claim id.');
    const claim = await InsuranceClaim.findOne({ _id: req.params.id, driverId: req.driver._id }).lean();
    return claim ? res.json({ success: true, data: claim }) : fail(res, 404, 'Claim not found.');
  } catch (e) { return next(e); }
};

exports.addDocument = async (req, res, next) => {
  try {
    if (!id(req.params.id)) return fail(res, 400, 'Invalid claim id.');
    const { fileName, mimeType, data } = req.body || {};
    const allowed = ['image/jpeg', 'image/png', 'application/pdf'];
    if (!fileName || !allowed.includes(mimeType) || typeof data !== 'string') return fail(res, 400, 'fileName, supported mimeType and base64 data are required.');
    const raw = data.replace(/^data:[^;]+;base64,/, '');
    const buffer = Buffer.from(raw, 'base64');
    if (!buffer.length || buffer.length > 5 * 1024 * 1024) return fail(res, 400, 'Document must be between 1 byte and 5 MB.');
    const claim = await InsuranceClaim.findOne({ _id: req.params.id, driverId: req.driver._id });
    if (!claim) return fail(res, 404, 'Claim not found.');
    const doc = await InsuranceDocument.create({ driverId: req.driver._id, claimId: claim._id, fileName, mimeType, size: buffer.length, data: buffer });
    return res.status(201).json({ success: true, data: { _id: doc._id, fileName, mimeType, size: buffer.length } });
  } catch (e) { return next(e); }
};

exports.getDocument = async (req, res, next) => {
  try {
    if (!id(req.params.id)) return fail(res, 400, 'Invalid document id.');
    const doc = await InsuranceDocument.findOne({ _id: req.params.id, driverId: req.driver._id }).select('+data');
    if (!doc) return fail(res, 404, 'Document not found.');
    res.set({ 'Content-Type': doc.mimeType, 'Content-Length': String(doc.size), 'Content-Disposition': `inline; filename="${doc.fileName.replace(/["\\\r\n]/g, '')}"` });
    return res.send(doc.data);
  } catch (e) { return next(e); }
};

exports.faqs = async (req, res) => res.json({ success: true, data: [] });
