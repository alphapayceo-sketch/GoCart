import crypto from 'crypto';
import ledgerService from './ledgerService.js';
import db from '../../config/db.js';

// Default to local in-process mock gateway mounted on the same server
const MOCK_GATEWAY = process.env.MTN_MOCK_GATEWAY || 'http://localhost:3000/mock-mtn';
const WEBHOOK_SECRET = process.env.MTN_WEBHOOK_SECRET || 'change_me_in_prod';

class MtnMockService {
  async initiateCollection(tenantId, mobile, amountCents, externalRef) {
    const inserted = await db('orders').insert({ tenant_id: tenantId, total_amount: amountCents / 100.0, status: 'INITIATED', external_ref: externalRef }).returning('id');
    const orderId = Array.isArray(inserted) ? (inserted[0].id || inserted[0]) : inserted;

    const payload = { mobile, amountCents, externalRef };
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000);

    try {
      const resp = await fetch(`${MOCK_GATEWAY}/ussd/push`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });
      clearTimeout(timeout);
      if (!resp.ok) {
        await db('orders').where({ id: orderId }).update({ status: 'FAILED' });
        return { status: 'gateway_error', statusCode: resp.status };
      }
      const data = await resp.json();
      return { status: 'initiated', providerRef: data.requestId || null, orderId };
    } catch (err) {
      clearTimeout(timeout);
      if (err.name === 'AbortError') {
        await db('orders').where({ id: orderId }).update({ status: 'PENDING' });
        return { status: 'timeout', message: 'USSD push timed out; awaiting webhook' };
      }
      await db('orders').where({ id: orderId }).update({ status: 'FAILED' });
      return { status: 'error', error: String(err) };
    }
  }

  async momoWebhookHandler(rawBody, headers) {
    const sig = headers['x-mtn-signature'] || headers['x-mtn-signature'.toLowerCase()];
    if (!sig) throw new Error('missing signature');
    const computed = crypto.createHmac('sha256', WEBHOOK_SECRET).update(rawBody).digest('hex');
    if (!crypto.timingSafeEqual(Buffer.from(computed), Buffer.from(sig))) throw new Error('invalid signature');

    const payload = JSON.parse(rawBody);
    const { externalRef, status, amountCents, tenantId } = payload;

    if (status === 'SUCCESSFUL') {
      const order = await db('orders').where({ external_ref: externalRef }).first();
      if (order) await db('orders').where({ id: order.id }).update({ status: 'PAID' });
      const r = await ledgerService.handlePaymentConfirmation({ externalRef, tenantId: tenantId || (order && order.tenant_id) || '', amountCents });
      return r;
    }

    if (status === 'FAILED') {
      await db('orders').where({ external_ref: externalRef }).update({ status: 'FAILED' });
      await db('transactions').where({ external_ref: externalRef }).update({ status: 'FAILED' });
      return { status: 'marked_failed' };
    }

    await db('orders').where({ external_ref: externalRef }).update({ status: 'PENDING' });
    return { status: 'pending' };
  }
}

export default new MtnMockService();
