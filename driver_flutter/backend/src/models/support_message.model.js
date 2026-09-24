const mongoose = require('mongoose');

const supportMessageSchema = new mongoose.Schema(
  {
    driver: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true, index: true },
    body: { type: String, required: true, trim: true, maxlength: 2000 },
    sender: { type: String, enum: ['driver', 'support'], default: 'driver' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('SupportMessage', supportMessageSchema);
