-- 002_seed_sample_data.sql
USE app_db;

INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Admin', 'admin@example.com', '9999990000', 'placeholder-hash', 'admin');

INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Owner Rita', 'owner.rita@example.com', '9999990001', 'placeholder-hash', 'restaurant_owner');

INSERT INTO users (name, email, phone, password_hash, role)
VALUES ('Customer Aman', 'aman@example.com', '9999990002', 'placeholder-hash', 'customer');

-- create restaurant owned by Owner Rita (user id 2)
INSERT INTO restaurants (owner_user_id, name, address, is_active, status)
VALUES (2, 'Rita''s Kitchen', '56 Market St', 1, 'approved');

-- create profile for restaurant 1
INSERT INTO restaurant_profiles (restaurant_id, fssai_number, images, license_docs, verified_by, verified_at)
VALUES (1, 'FSSAI12345', 'r1_img1.jpg,r1_img2.jpg', 'r1_license.pdf', 1, NOW());

-- menu items (prices in paise)
INSERT INTO menu_items (restaurant_id, name, description, price_cents, discount_percent, sale_price_cents)
VALUES
(1, 'Paneer Butter Masala', 'Creamy paneer curry', 25000, 20, 20000),
(1, 'Garlic Naan', 'Soft garlic naan', 5000, 0, 5000),
(1, 'Jeera Rice', 'Fragrant rice', 12000, 10, 10800);

-- create wallet for restaurant 1
INSERT INTO wallets (restaurant_id, balance_cents, pending_cents)
VALUES (1, 0, 0);
