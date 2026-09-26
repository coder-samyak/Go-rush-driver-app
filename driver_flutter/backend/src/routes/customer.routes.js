const express = require('express');
const controller = require('../controllers/customerAuth.controller');
const { protectCustomer } = require('../middleware/customerAuth.middleware');

const router = express.Router();
const walletController = require('../controllers/customerWallet.controller');

router.post('/auth/send-otp', controller.sendOtp);
router.post('/auth/verify-otp', controller.verifyOtp);
router.post('/auth/register', controller.register);
router.post('/auth/login-password', controller.login);
router.get('/auth/me', protectCustomer, controller.me);

router.get('/wallet', protectCustomer, walletController.getWallet);
router.post('/wallet/add-money', protectCustomer, walletController.addMoney);
router.get('/wallet/transactions', protectCustomer, walletController.getTransactions);
router.get('/wallet/refunds', protectCustomer, walletController.getRefunds);
router.get('/wallet/payment-methods', protectCustomer, walletController.getPaymentMethods);
router.post('/wallet/payment-methods', protectCustomer, walletController.addPaymentMethod);
router.post('/wallet/payment-methods/:id/set-default', protectCustomer, walletController.setDefaultPaymentMethod);
router.delete('/wallet/payment-methods/:id', protectCustomer, walletController.deletePaymentMethod);
router.get('/wallet/promo-credits', protectCustomer, walletController.getPromoCredits);
router.post('/wallet/redeem-promo', protectCustomer, walletController.redeemPromo);

module.exports = router;
