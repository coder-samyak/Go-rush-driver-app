const express = require('express');
const controller = require('../controllers/customerRide.controller');
const { protectCustomer } = require('../middleware/customerAuth.middleware');

const router = express.Router();
router.use(protectCustomer);
router.post('/quotes', controller.createQuote);
router.get('/quotes/:quoteId', controller.getQuote);
router.post('/rides', controller.createRide);
router.get('/rides', controller.getRides);
router.get('/rides/active', controller.getActiveRide);
router.get('/rides/:rideId', controller.getRide);
router.post('/rides/:rideId/cancel', controller.cancelRide);
router.post('/rides/:rideId/rating', controller.submitRating);
router.post('/rides/:rideId/issue', controller.reportIssue);
router.post('/rides/:rideId/lost-item', controller.reportLostItem);
router.get('/rides/:rideId/receipt', controller.getReceipt);
module.exports = router;
