const router = require('express').Router();
const controller = require('../controllers/safety.controller');
const { protect } = require('../middleware/auth.middleware');

router.post('/sos', protect, controller.triggerSos);
router.post('/sos/:alertId/resolve', protect, controller.resolveSos);
module.exports = router;
