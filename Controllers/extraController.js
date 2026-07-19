import db from '../config/db.js';

// Review Controllers
export const getProductReviews = async (req, res) => {
  const { product_id } = req.params;
  try {
    const reviews = await db('reviews')
      .where({ product_id })
      .join('users', 'reviews.user_id', '=', 'users.id')
      .select('reviews.*', 'users.first_name', 'users.last_name')
      .orderBy('created_at', 'desc');
    res.json(reviews);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const addReview = async (req, res) => {
  const { product_id } = req.params;
  const { rating, comment } = req.body;
  try {
    const [review] = await db('reviews').insert({
      product_id,
      user_id: req.user.id,
      rating,
      comment
    }).returning('*');
    res.status(201).json(review);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

// Wishlist Controllers
export const getWishlist = async (req, res) => {
  try {
    const wishlist = await db('wishlists')
      .where({ user_id: req.user.id })
      .join('products', 'wishlists.product_id', '=', 'products.id')
      .select('wishlists.*', 'products.name', 'products.price', 'products.image_urls');
    res.json(wishlist);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const addToWishlist = async (req, res) => {
  const { product_id } = req.body;
  try {
    const existing = await db('wishlists').where({ user_id: req.user.id, product_id }).first();
    if (existing) {
      return res.status(400).json({ message: 'Product already in wishlist' });
    }
    const [item] = await db('wishlists').insert({
      user_id: req.user.id,
      product_id
    }).returning('*');
    res.status(201).json(item);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const removeFromWishlist = async (req, res) => {
  const { product_id } = req.params;
  try {
    await db('wishlists').where({ user_id: req.user.id, product_id }).del();
    res.json({ message: 'Removed from wishlist' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};
