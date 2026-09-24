const express = require('express');
const { protect } = require('../middleware/auth.middleware');
const controller = require('../controllers/insurance.controller');

const router = express.Router();
router.use(protect);
router.get('/policy', controller.policy);
router.get('/my-policy', controller.myPolicy);
router.post('/enroll', controller.enroll);
router.get('/ride/:rideId', controller.ridePolicy);
router.post('/claim', controller.createClaim);
router.get('/claims', controller.listClaims);
router.get('/claim/:id', controller.getClaim);
router.post('/claim/:id/documents', controller.addDocument);
router.get('/documents/:id', controller.getDocument);
router.get('/faqs', controller.faqs);
module.exports = router;
