import express from 'express';
import cors from 'cors';
import router from './index.js';
import env from './env.js';

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Mount API routes
app.use('/api', router);

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || env.PORT || 3000;
app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Server listening on port ${PORT}`);
});
