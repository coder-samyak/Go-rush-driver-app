const SupportTicket = require('../models/support_ticket.model');

function ticketNumber() {
  return `GR-${Date.now().toString().slice(-8)}-${Math.floor(100 + Math.random() * 900)}`;
}

exports.listTickets = async (req, res) => {
  try {
    const tickets = await SupportTicket.find({ driverId: req.driver._id })
      .sort({ createdAt: -1 }).lean();
    return res.json({ success: true, data: tickets });
  } catch (_) {
    return res.status(500).json({ success: false, message: 'Unable to load support tickets.' });
  }
};

exports.createTicket = async (req, res) => {
  try {
    const { title, category, description, amount } = req.body;
    if (![title, category, description].every((value) => typeof value === 'string' && value.trim())) {
      return res.status(400).json({ success: false, message: 'Title, category and details are required.' });
    }
    const ticket = await SupportTicket.create({
      driverId: req.driver._id, ticketNumber: ticketNumber(), title, category, description,
      amount: Number.isFinite(Number(amount)) ? Number(amount) : 0,
    });
    return res.status(201).json({ success: true, data: ticket });
  } catch (_) {
    return res.status(500).json({ success: false, message: 'Unable to create support ticket.' });
  }
};
