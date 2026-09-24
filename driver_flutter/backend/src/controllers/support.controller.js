const SupportMessage = require('../models/support_message.model');

exports.createMessage = async (req, res) => {
  try {
    const body = typeof req.body.message === 'string' ? req.body.message.trim() : '';
    if (!body) return res.status(400).json({ success: false, message: 'A support message is required.' });
    const message = await SupportMessage.create({ driver: req.driver._id, body });
    req.app.locals.io?.to('support:inbox').emit('support:message', {
      id: message._id, driverId: req.driver._id, body: message.body, createdAt: message.createdAt,
    });
    return res.status(201).json({ success: true, data: message });
  } catch (_) {
    return res.status(500).json({ success: false, message: 'Unable to send support message' });
  }
};
