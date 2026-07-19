import db from '../config/db.js';
import logger from '../logger.js';

// Cart Controllers
export const getCart = async (req, res) => {
  try {
    const cart = await db('carts').where({ user_id: req.user.id }).first();
    if (!cart) {
      return res.status(404).json({ message: 'Cart not found' });
    }

    const items = await db('cart_items')
      .where({ cart_id: cart.id })
      .join('products', 'cart_items.product_id', '=', 'products.id')
      .select('cart_items.*', 'products.name', 'products.price', 'products.image_urls');

    res.json({ ...cart, items });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

export const addToCart = async (req, res) => {
  const { product_id, variant_id, quantity = 1 } = req.body;

  try {
    const cart = await db('carts').where({ user_id: req.user.id }).first();
    
    // Check if item already exists in cart
    const existingItem = await db('cart_items')
      .where({ cart_id: cart.id, product_id, variant_id })
      .first();

    if (existingItem) {
      await db('cart_items')
        .where({ id: existingItem.id })
        .update({ quantity: existingItem.quantity + quantity });
    } else {
      await db('cart_items').insert({
        cart_id: cart.id,
        product_id,
        variant_id,
        quantity
      });
    }

    res.status(201).json({ message: 'Product added to cart' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

export const updateCartItem = async (req, res) => {
  const { id } = req.params;
  const { quantity } = req.body;
  try {
    const cart = await db('carts').where({ user_id: req.user.id }).first();
    const updated = await db('cart_items')
      .where({ id, cart_id: cart.id })
      .update({ quantity });
    if (!updated) return res.status(404).json({ message: 'Cart item not found' });
    res.json({ message: 'Cart item updated' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const deleteCartItem = async (req, res) => {
  const { id } = req.params;
  try {
    const cart = await db('carts').where({ user_id: req.user.id }).first();
    const deleted = await db('cart_items')
      .where({ id, cart_id: cart.id })
      .del();
    if (!deleted) return res.status(404).json({ message: 'Cart item not found' });
    res.json({ message: 'Cart item removed' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

// Order Controllers
export const createOrder = async (req, res) => {
  const { shipping_address_id } = req.body;

  const trx = await db.transaction();

  try {
    const cart = await trx('carts').where({ user_id: req.user.id }).first();
    const cartItems = await trx('cart_items')
      .where({ cart_id: cart.id })
      .join('products', 'cart_items.product_id', '=', 'products.id')
      .select('cart_items.*', 'products.price', 'products.stock_quantity');

    if (cartItems.length === 0) {
      await trx.rollback();
      return res.status(400).json({ message: 'Cart is empty' });
    }

    // Check stock and calculate total
    let totalAmount = 0;
    for (const item of cartItems) {
      if (item.stock_quantity < item.quantity) {
        await trx.rollback();
        return res.status(400).json({ message: `Insufficient stock for product ${item.product_id}` });
      }
      totalAmount += item.price * item.quantity;
      
      // Reduce stock
      await trx('products')
        .where({ id: item.product_id })
        .decrement('stock_quantity', item.quantity);
    }

    const [order] = await trx('orders').insert({
      user_id: req.user.id,
      shipping_address_id,
      total_amount: totalAmount,
      status: 'pending'
    }).returning('*');

    const orderItems = cartItems.map(item => ({
      order_id: order.id,
      product_id: item.product_id,
      variant_id: item.variant_id,
      quantity: item.quantity,
      price_at_purchase: item.price
    }));

    await trx('order_items').insert(orderItems);

    // Clear cart
    await trx('cart_items').where({ cart_id: cart.id }).del();

    await trx.commit();
    res.status(201).json({ message: 'Order placed successfully', order });
  } catch (err) {
    await trx.rollback();
    logger.error('Order creation failed:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

export const getOrders = async (req, res) => {
  try {
    const orders = await db('orders').where({ user_id: req.user.id }).orderBy('created_at', 'desc');
    
    // For each order, get items
    const ordersWithItems = await Promise.all(orders.map(async (order) => {
      const items = await db('order_items')
        .where({ order_id: order.id })
        .join('products', 'order_items.product_id', '=', 'products.id')
        .select('order_items.*', 'products.name', 'products.image_urls');
      return { ...order, items };
    }));

    res.json(ordersWithItems);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};
