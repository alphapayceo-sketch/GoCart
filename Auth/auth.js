import jwt from 'jsonwebtoken';
import env from '../config/env.js';
import db from '../config/db.js';

export const normalizeRole = (role) => {
  const value = String(role || '').trim().toLowerCase();

  if (!value || ['user', 'customer', 'buyer'].includes(value)) {
    return 'customer';
  }

  if (['merchant', 'seller', 'vendor', 'shop_owner', 'shopowner'].includes(value)) {
    return 'merchant';
  }

  if (['admin', 'superadmin', 'super_admin'].includes(value)) {
    return 'admin';
  }

  return value;
};

export const auth = async (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ message: 'No token, authorization denied' });
  }

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    const user = await db('users').where({ id: decoded.id }).first();

    if (!user) {
      return res.status(401).json({ message: 'User not found' });
    }

    req.user = { ...user, role: normalizeRole(user.role) };
    next();
  } catch (err) {
    res.status(401).json({ message: 'Token is not valid' });
  }
};

export const authorize = (...roles) => {
  const allowedRoles = new Set(roles.map(normalizeRole));

  return (req, res, next) => {
    if (!req.user || !allowedRoles.has(normalizeRole(req.user.role))) {
      return res.status(403).json({ message: 'User role not authorized to access this route' });
    }
    next();
  };
};
