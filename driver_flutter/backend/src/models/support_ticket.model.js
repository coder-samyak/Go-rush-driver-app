const mongoose = require('mongoose');

const supportTicketSchema = new mongoose.Schema({
  driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true, index: true },
  ticketNumber: { type: String, required: true, unique: true, index: true },
  title: { type: String, required: true, trim: true, maxlength: 140 },
  category: { type: String, required: true, trim: true, maxlength: 60 },
  description: { type: String, required: true, trim: true, maxlength: 2000 },
  amount: { type: Number, default: 0, min: 0 },
  status: { type: String, enum: ['active', 'resolved'], default: 'active', index: true },
  resolvedAt: { type: Date, default: null },
}, { timestamps: true, collection: 'support_tickets' });

module.exports = mongoose.model('SupportTicket', supportTicketSchema);
