const SosAlert = require('../models/sos_alert.model');

exports.triggerSos = async (req, res) => {
  try {
    const { lat, lng, accuracy, rideId } = req.body;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      return res.status(400).json({ success: false, message: 'A valid GPS location is required for SOS.' });
    }
    const alert = await SosAlert.create({
      driverId: req.driver._id, rideId: rideId || null,
      location: { lat, lng, accuracy: Number.isFinite(accuracy) ? accuracy : null },
    });
    const io = req.app.locals.io;
    if (io) io.emit('sos:alert', alert.toObject());
    return res.status(201).json({ success: true, data: alert.toObject() });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Unable to create SOS alert', error: err.message });
  }
};

exports.resolveSos = async (req, res) => {
  const alert = await SosAlert.findOneAndUpdate(
    { _id: req.params.alertId, driverId: req.driver._id, status: 'active' },
    { status: 'resolved', resolvedAt: new Date() }, { new: true },
  );
  if (!alert) return res.status(404).json({ success: false, message: 'Active SOS alert not found' });
  return res.json({ success: true, data: alert.toObject() });
};
