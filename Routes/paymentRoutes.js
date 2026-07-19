import express from 'express';
import { createCheckoutSession, handleWebhook } from '../Controllers/paymentController.js';
import { auth } from '../Auth/auth.js';

const router = express.Router();

router.post('/create-checkout-session', auth, createCheckoutSession);

// Webhook needs raw body, handled in index.js
router.post('/webhook', express.raw({ type: 'application/json' }), handleWebhook);

export default router;
