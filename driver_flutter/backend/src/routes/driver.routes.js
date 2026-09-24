const express = require('express');
const router = express.Router();
const driverController = require('../controllers/driver.controller');
const incentiveController = require('../controllers/incentive.controller');
const walletRoutes = require('./wallet.routes');
const { protect, optionalProtect } = require('../middleware/auth.middleware');

// PUT /api/driver/status - Toggle online/offline status
router.put('/status', optionalProtect, driverController.updateStatus);
router.patch('/status', optionalProtect, driverController.updateStatus);

// GET /api/driver/status - Get current driver status
router.get('/status', optionalProtect, driverController.getStatus);

// GET /api/driver/incentives - live incentives for the logged-in driver
router.get('/incentives', protect, incentiveController.getIncentives);

// Mount wallet sub-routes: /api/driver/wallet/*
router.use('/wallet', walletRoutes);

module.exports = router;
