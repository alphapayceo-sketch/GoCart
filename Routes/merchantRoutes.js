import express from 'express';
import {
  getStats,
  getAdminOrders,
  getAdminProducts,
  createProduct,
  updateProduct,
  deleteProduct,
  getAdminCategories,
  createCategory,
  updateCategory,
  deleteCategory,
} from '../Controllers/adminController.js';
import { auth, authorize } from '../Auth/auth.js';
import { upload } from '../upload.js';

const router = express.Router();

router.use(auth);
router.use(authorize('merchant', 'admin'));

router.get('/stats', getStats);
router.get('/orders', getAdminOrders);
router.get('/categories', getAdminCategories);
router.post('/categories', createCategory);
router.put('/categories/:id', updateCategory);
router.delete('/categories/:id', deleteCategory);
router.get('/products', getAdminProducts);
router.post('/products', upload.array('images', 5), createProduct);
router.put('/products/:id', upload.array('images', 5), updateProduct);
router.delete('/products/:id', deleteProduct);

export default router;
