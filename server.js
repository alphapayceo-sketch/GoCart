import express from 'express';
import cors from 'cors';
import http from 'http';
import router from './index.js';
import env from './env.js';
import { initSocket, emitNotification } from './socket.js';
import mockGateway from './src_js/fintech/mockGateway.js';

const app = express();
app.use(cors({ origin: true }));
// Ensure the webhook route can access the raw body for signature verification
app.use('/api/momo/webhook', express.raw({ type: '*/*' }));
app.use(express.json());

// Mount internal mock MTN gateway for deterministic testing
app.use('/mock-mtn', mockGateway);

// Mount API routes
app.use('/api', router);

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// Development helper: emit a test notification.
app.post('/emit-test', (req, res) => {
  const payload = req.body || {
    title: 'Test notification',
    message: 'This is a test notification from /emit-test',
    timestamp: new Date().toISOString(),
  };

  try {
    emitNotification(payload);
    res.json({ ok: true, payload });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

const PORT = process.env.PORT || env.PORT || 3000;
const server = http.createServer(app);
const io = initSocket(server);

server.on('error', (err) => {
  // eslint-disable-next-line no-console
  if (err && err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} already in use. Is another server running?`);
    console.error('If you want to free the port, find and stop the process using it (Windows: `netstat -ano | findstr :${PORT}` then `taskkill /PID <pid> /F`).');
    process.exit(1);
  }
  console.error('Server error:', err);
  process.exit(1);
});

try {
  server.listen(PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`Server listening on port ${PORT}`);
  });
} catch (err) {
  // eslint-disable-next-line no-console
  if (err && err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} already in use. Is another server running?`);
  } else {
    console.error('Failed to start server synchronously:', err);
  }
  process.exit(1);
}
