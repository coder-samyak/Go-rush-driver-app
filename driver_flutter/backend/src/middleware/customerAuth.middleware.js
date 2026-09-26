const jwt = require('jsonwebtoken');
const config = require('../config/env');
const Customer = require('../models/customer.model');

const protectCustomer = async (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ success: false, message: 'Customer authentication required.' });
  }

  try {
    const decoded = jwt.verify(token, config.jwt.secret);
    if (decoded.role !== 'customer') {
      return res.status(403).json({ success: false, message: 'Customer access required.' });
    }
    const customer = await Customer.findById(decoded.id);
    if (!customer || customer.status !== 'active') {
      return res.status(401).json({ success: false, message: 'Customer account is unavailable.' });
    }
    req.customer = customer;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: error.name === 'TokenExpiredError' ? 'Session expired. Please log in again.' : 'Invalid customer session.',
    });
  }
};

module.exports = { protectCustomer };
