import db from '../config/db.js';
import logger from './logger.js';

export const logActivity = async (req, action, resource, resourceId = null, oldValue = null, newValue = null) => {
  try {
    await db('audit_logs').insert({
      user_id: req.user ? req.user.id : null,
      action,
      resource,
      resource_id: resourceId,
      old_value: oldValue ? JSON.stringify(oldValue) : null,
      new_value: newValue ? JSON.stringify(newValue) : null,
      ip_address: req.ip,
      user_agent: req.headers['user-agent']
    });
  } catch (err) {
    logger.error('Failed to log audit activity:', err);
  }
};
