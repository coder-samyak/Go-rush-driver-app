const express = require('express');
const router = express.Router();
const walletController = require('../controllers/wallet.controller');
const { protect } = require('../middleware/auth.middleware');

// GET /api/driver/wallet — wallet balance + status
router.get('/', protect, walletController.getWallet);

// GET /api/driver/wallet/status — quick balance sufficiency check
router.get('/status', protect, walletController.getWalletStatus);

// GET /api/driver/wallet/transactions — full transaction ledger
router.get('/transactions', protect, walletController.getTransactions);

// GET /api/driver/wallet/config — platform config (charge rate, minimum balance)
router.get('/config', protect, walletController.getPlatformConfig);

// POST /api/driver/wallet/recharge — add money to wallet
router.post('/recharge', protect, walletController.recharge);

module.exports = router;
