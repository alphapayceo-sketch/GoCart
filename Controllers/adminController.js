import db from '../config/db.js';

export const getStats = async (req, res) => {
  try {
    const totalSales = await db('orders').where({ status: 'paid' }).sum('total_amount as total');
    const orderCount = await db('orders').count('id as count');
    const userCount = await db('users').count('id as count');
    const productCount = await db('products').count('id as count');

    res.json({
      total_revenue: parseFloat(totalSales[0].total || 0),
      total_orders: parseInt(orderCount[0].count),
      total_users: parseInt(userCount[0].count),
      total_products: parseInt(productCount[0].count)
    });
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch stats' });
  }
};

export const getAdminOrders = async (req, res) => {
  try {
    const orders = await db('orders')
      .join('users', 'orders.user_id', '=', 'users.id')
      .select('orders.*', 'users.email', 'users.first_name', 'users.last_name')
      .orderBy('created_at', 'desc');
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch orders' });
  }
};
