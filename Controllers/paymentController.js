import stripe from '../config/stripe.js';
import db from '../config/db.js';
import env from '../config/env.js';
import logger from '../logger.js';

export const createCheckoutSession = async (req, res) => {
  const { order_id } = req.body;

  try {
    const order = await db('orders').where({ id: order_id, user_id: req.user.id }).first();
    if (!order) return res.status(404).json({ message: 'Order not found' });

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: `Order #${order.id}`,
            },
            unit_amount: Math.round(order.total_amount * 100),
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${req.protocol}://${req.get('host')}/api/payments/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${req.protocol}://${req.get('host')}/api/payments/cancel`,
      metadata: { order_id: order.id },
    });

    res.json({ url: session.url });
  } catch (err) {
    logger.error('Stripe session creation failed:', err);
    res.status(500).json({ message: 'Payment initiation failed' });
  }
};

export const handleWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    logger.error('Webhook signature verification failed:', err);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const orderId = session.metadata.order_id;

    try {
      await db('orders').where({ id: orderId }).update({ status: 'paid' });
      logger.info(`Order ${orderId} marked as paid.`);
    } catch (err) {
      logger.error(`Failed to update order ${orderId}:`, err);
    }
  }

  res.json({ received: true });
};
