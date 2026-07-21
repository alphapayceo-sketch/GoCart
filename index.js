import express from 'express';
import authRoutes from './Routes/authRoutes.js';
import productRoutes from './Routes/productRoutes.js';
import cartOrderRoutes from './Routes/cartOrderRoutes.js';
import userRoutes from './Routes/userRoutes.js';
import extraRoutes from './Routes/extraRoutes.js';
import mediaRoutes from './Routes/mediaRoutes.js';
import adminRoutes from './Routes/adminRoutes.js';

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/products', productRoutes);
router.use('/', cartOrderRoutes);
router.use('/users', userRoutes);
router.use('/', extraRoutes);
router.use('/media', mediaRoutes);
router.use('/admin', adminRoutes);

export default router;
