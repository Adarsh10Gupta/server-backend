-- 001_init_schema.sql
CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE app_db;

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(50),
  password_hash VARCHAR(255),
  role ENUM('customer','restaurant_owner','admin') DEFAULT 'customer',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ADDRESSES
CREATE TABLE IF NOT EXISTS addresses (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  label VARCHAR(50),
  address_line TEXT,
  city VARCHAR(100),
  pincode VARCHAR(20),
  lat DECIMAL(10,7) NULL,
  lng DECIMAL(10,7) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- RESTAURANTS TABLE (UPDATED)
CREATE TABLE IF NOT EXISTS restaurants (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  owner_user_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  address TEXT,
  is_active TINYINT(1) DEFAULT 0,
  status ENUM('pending','approved','declined') DEFAULT 'pending',

  -- NEW FIELDS
  delivery_price_per_km INT DEFAULT 10,     -- delivery charge per kilometer
  is_pure_veg TINYINT(1) DEFAULT 0,         -- 0 = non-veg, 1 = pure veg

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- RESTAURANT PROFILES
CREATE TABLE IF NOT EXISTS restaurant_profiles (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id BIGINT NOT NULL,
  fssai_number VARCHAR(100),
  images TEXT,
  license_docs TEXT,
  verified_by BIGINT NULL,
  verified_at TIMESTAMP NULL,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- MENU ITEMS (UPDATED)
CREATE TABLE IF NOT EXISTS menu_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id BIGINT NOT NULL,
  name VARCHAR(255),
  description TEXT,
  price_cents BIGINT NOT NULL,
  discount_percent INT DEFAULT 0,
  sale_price_cents BIGINT DEFAULT NULL,
  is_available TINYINT(1) DEFAULT 1,

  -- NEW FIELD (veg / non-veg)
  is_veg TINYINT(1) DEFAULT 1,              -- 1 = veg, 0 = non-veg

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- ORDERS
CREATE TABLE IF NOT EXISTS orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(80) UNIQUE,
  restaurant_id BIGINT NOT NULL,
  customer_id BIGINT NOT NULL,
  address_id BIGINT NULL,
  total_cents BIGINT NOT NULL,
  payment_status ENUM('pending','paid','failed') DEFAULT 'pending',
  order_status ENUM('placed','accepted','preparing','ready','completed','cancelled') DEFAULT 'placed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (address_id) REFERENCES addresses(id)
);

-- ORDER ITEMS
CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  menu_item_id BIGINT NOT NULL,
  qty INT DEFAULT 1,
  price_cents BIGINT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- WALLETS
CREATE TABLE IF NOT EXISTS wallets (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id BIGINT UNIQUE NOT NULL,
  balance_cents BIGINT DEFAULT 0,
  pending_cents BIGINT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- WALLET TRANSACTIONS
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  wallet_id BIGINT NOT NULL,
  order_id BIGINT NULL,
  type ENUM('credit','debit') NOT NULL,
  amount_cents BIGINT NOT NULL,
  balance_after_cents BIGINT NOT NULL,
  note VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (wallet_id) REFERENCES wallets(id),
  FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- ORDER FEES
CREATE TABLE IF NOT EXISTS order_fees (
  order_id BIGINT PRIMARY KEY,
  commission_cents BIGINT NOT NULL,
  restaurant_share_cents BIGINT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id)
);
