const express = require('express');
const router = express.Router();
const rideController = require('../controllers/ride.controller');
const { protect, optionalProtect } = require('../middleware/auth.middleware');

// GET /api/payment/earnings - Driver earnings & completed trip revenue
router.get('/earnings', optionalProtect, rideController.getEarnings);

// GET /api/payment/summary - Payment summary overview
router.get('/summary', optionalProtect, rideController.getEarnings);

// GET /api/payment/methods - Available payment options
router.get('/methods', (req, res) => {
  res.status(200).json({
    success: true,
    data: {
      acceptedMethods: ['Cash', 'UPI', 'GoRush Wallet', 'Card'],
      defaultMethod: 'Cash / UPI',
    },
  });
});

// GET /api/payment/ - Default payment root for chatbot health/ping
router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    service: 'GoRush Payment Service',
    endpoints: {
      earnings: 'GET /api/payment/earnings',
      summary: 'GET /api/payment/summary',
      methods: 'GET /api/payment/methods',
    },
  });
});

module.exports = router;
