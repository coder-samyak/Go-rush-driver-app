const express = require('express');
const { protect } = require('../middleware/auth.middleware');
const supportController = require('../controllers/support.controller');
const ticketController = require('../controllers/support_ticket.controller');

const router = express.Router();
router.post('/messages', protect, supportController.createMessage);
router.get('/tickets', protect, ticketController.listTickets);
router.post('/tickets', protect, ticketController.createTicket);
module.exports = router;
