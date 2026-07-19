import express from 'express';
import { getProfile, getAddresses, addAddress, updateAddress, deleteAddress } from '../controllers/userController.js';
import { auth } from '../Auth/auth.js';

const router = express.Router();

router.use(auth);

router.get('/me', getProfile);
router.get('/me/addresses', getAddresses);
router.post('/me/addresses', addAddress);
router.put('/me/addresses/:id', updateAddress);
router.delete('/me/addresses/:id', deleteAddress);

export default router;
