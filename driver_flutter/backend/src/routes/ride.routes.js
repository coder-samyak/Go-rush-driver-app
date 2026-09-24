const express = require('express');
const router = express.Router();
const rideController = require('../controllers/ride.controller');
const { protect, optionalProtect } = require('../middleware/auth.middleware');

// GET /api/rides/available - Fetch pending/available incoming ride offer
router.get('/available', optionalProtect, rideController.getAvailableRide);

// GET /api/rides/active - Current active trip for logged-in driver
router.get('/active', protect, rideController.getActiveRide);

// POST /api/rides/:rideId/accept - Accept incoming ride
router.post('/:rideId/accept', protect, rideController.acceptRide);

// POST /api/rides/:rideId/reject - Reject incoming ride
router.post('/:rideId/reject', protect, rideController.rejectRide);

// POST /api/rides/:rideId/arrived - Mark arrival at pickup location
router.post('/:rideId/arrived', protect, rideController.markArrived);

// POST /api/rides/:rideId/start - Verify OTP & start trip
router.post('/:rideId/start', protect, rideController.startTrip);

// POST /api/rides/:rideId/complete - Complete trip & finalize fare
router.post('/:rideId/complete', protect, rideController.completeTrip);
router.put('/:rideId/location', protect, rideController.updateLocation);

// GET /api/rides/history - Separated completed & cancelled trip history
router.get('/history', protect, rideController.getHistory);

// GET /api/rides/earnings - Aggregated driver earnings
router.get('/earnings', protect, rideController.getEarnings);

module.exports = router;
