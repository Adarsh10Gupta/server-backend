-- 002_seed_sample_data.sql
USE app_db;

-- NOTE: password_hash values are placeholders. Replace with real bcrypt hashes in production.
INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Admin', 'admin@example.com', '9999990000', 'placeholder-hash', 'admin');

INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Owner Rita', 'owner.rita@example.com', '9999990001', 'placeholder-hash', 'restaurant_owner');

INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Customer Aman', 'aman@example.com', '9999990002', 'placeholder-hash', 'customer');

-- create restaurant owned by Owner Rita (user id 2)
-- delivery_price_per_km stored in smallest currency units? Using rupees as integer here (e.g., 10 = ₹10 per km).
INSERT INTO restaurants (owner_user_id, name, address, is_active, status, delivery_price_per_km, is_pure_veg)
VALUES (2, 'Rita''s Kitchen', '56 Market St', 1, 'approved', 10, 0);

-- create profile for restaurant 1
INSERT INTO restaurant_profiles (restaurant_id, fssai_number, images, license_docs, verified_by, verified_at)
VALUES (1, 'FSSAI12345', 'r1_img1.jpg,r1_img2.jpg', 'r1_license.pdf', 1, NOW());

-- menu items for restaurant 1 (prices in paise)
-- is_veg: 1 = veg, 0 = non-veg
INSERT INTO menu_items (restaurant_id, name, description, price_cents, discount_percent, sale_price_cents, is_veg)
VALUES
(1, 'Paneer Butter Masala', 'Creamy paneer curry', 25000, 20, 20000, 1),
(1, 'Garlic Naan', 'Soft garlic naan', 5000, 0, 5000, 1),
(1, 'Chicken Tikka', 'Spicy grilled chicken', 30000, 10, 27000, 0),
(1, 'Jeera Rice', 'Fragrant rice', 12000, 10, 10800, 1);

-- create wallet for restaurant 1
INSERT INTO wallets (restaurant_id, balance_cents, pending_cents)
VALUES (1, 0, 0);

-- Optional extra restaurant (pure veg) for testing cross-restaurant behaviour
INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Owner PVR', 'owner.pvr@example.com', '9999990003', 'placeholder-hash', 'restaurant_owner');

INSERT INTO restaurants (owner_user_id, name, address, is_active, status, delivery_price_per_km, is_pure_veg)
VALUES (4, 'Pure Veg Delight', '99 Veg Lane', 1, 'approved', 8, 1);

INSERT INTO restaurant_profiles (restaurant_id, fssai_number, images, license_docs, verified_by, verified_at)
VALUES (2, 'FSSAI99999', 'pv_img1.jpg', 'pv_license.pdf', 1, NOW());

INSERT INTO menu_items (restaurant_id, name, description, price_cents, discount_percent, sale_price_cents, is_veg)
VALUES
(2, 'Veg Thali', 'Full veg thali', 18000, 0, 18000, 1),
(2, 'Paneer Tikka', 'Grilled paneer', 22000, 15, 18700, 1);

INSERT INTO wallets (restaurant_id, balance_cents, pending_cents)
VALUES (2, 0, 0);

-- Sample orders (optional): one paid order for restaurant 1
INSERT INTO orders (order_number, restaurant_id, customer_id, address_id, total_cents, payment_status, order_status)
VALUES ('ORD1001', 1, 3, NULL, 37000, 'paid', 'completed');

INSERT INTO order_items (order_id, menu_item_id, qty, price_cents)
VALUES
(1, 1, 1, 20000),
(1, 2, 2, 5000);

-- Record order fee split for ORD1001 (example: 1% commission)
INSERT INTO order_fees (order_id, commission_cents, restaurant_share_cents)
VALUES (1, FLOOR(37000 * 0.01), 37000 - FLOOR(37000 * 0.01));

-- Credit restaurant wallet for order 1 (simulate payout book)
-- first get wallet id for restaurant 1
INSERT INTO wallet_transactions (wallet_id, order_id, type, amount_cents, balance_after_cents, note)
VALUES (
  (SELECT id FROM wallets WHERE restaurant_id = 1 LIMIT 1),
  1,
  'credit',
  (SELECT restaurant_share_cents FROM order_fees WHERE order_id = 1),
  (SELECT COALESCE(balance_cents,0) + (SELECT restaurant_share_cents FROM order_fees WHERE order_id = 1) FROM wallets WHERE restaurant_id = 1),
  'Order ORD1001 credited after 1% commission'
);

-- update wallet balance (simple example)
UPDATE wallets
SET balance_cents = balance_cents + (SELECT restaurant_share_cents FROM order_fees WHERE order_id = 1)
WHERE restaurant_id = 1;
