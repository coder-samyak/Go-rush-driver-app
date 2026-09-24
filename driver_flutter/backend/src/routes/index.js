const express = require('express');
const router = express.Router();
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');
const rideRoutes = require('./ride.routes');
const driverRoutes = require('./driver.routes');
const safetyRoutes = require('./safety.routes');
const supportRoutes = require('./support.routes');
const paymentRoutes = require('./payment.routes');
const insuranceRoutes = require('./insurance.routes');

// Mount health check route: GET /api/health
router.use('/health', healthRoutes);

// Mount authentication routes: POST /api/auth/register, POST /api/auth/login
router.use('/auth', authRoutes);

// Mount rides routes: /api/rides/... and /api/ride/...
router.use('/rides', rideRoutes);
router.use('/ride', rideRoutes);

// Mount payment routes: /api/payment/...
router.use('/payment', paymentRoutes);
router.use('/insurance', insuranceRoutes);

// Mount driver, safety, and support routes
router.use('/driver', driverRoutes);
router.use('/safety', safetyRoutes);
router.use('/support', supportRoutes);

// Backward-compatible v1 aliases
router.use('/v1/rides', rideRoutes);
router.use('/v1/ride', rideRoutes);
router.use('/v1/payment', paymentRoutes);
router.use('/v1/driver', driverRoutes);
router.use('/v1/auth', authRoutes);

// Root API welcome info
router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to GoRush Driver Partner REST API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /api/health',
      register: 'POST /api/auth/register',
      login: 'POST /api/auth/login',
      rides: '/api/rides',
      driver: '/api/driver',
    },
  });
});

module.exports = router;
