import express from 'express';
import cors from 'cors';
import http from 'http';
import router from './index.js';
import env from './env.js';
import { initSocket, emitNotification } from './socket.js';

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

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

server.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Server listening on port ${PORT}`);
});
