-- 001_init_schema.sql
CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE app_db;

-- users
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(50),
  password_hash VARCHAR(255),
  role ENUM('customer','restaurant_owner','admin') DEFAULT 'customer',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- restaurants (status: pending/approved/declined)
CREATE TABLE IF NOT EXISTS restaurants (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  owner_user_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  address TEXT,
  is_active TINYINT(1) DEFAULT 0,
  status ENUM('pending','approved','declined') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- menu_items
CREATE TABLE IF NOT EXISTS menu_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id BIGINT NOT NULL,
  name VARCHAR(255),
  description TEXT,
  price_cents BIGINT NOT NULL,
  is_available TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (restaurant_id)
);

-- orders
CREATE TABLE IF NOT EXISTS orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(80) UNIQUE,
  restaurant_id BIGINT NOT NULL,
  customer_id BIGINT,
  total_cents BIGINT NOT NULL,
  payment_status ENUM('pending','paid','failed') DEFAULT 'pending',
  order_status ENUM('placed','accepted','preparing','ready','completed','cancelled') DEFAULT 'placed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (restaurant_id)
);

-- order_items
CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  menu_item_id BIGINT NOT NULL,
  qty INT DEFAULT 1,
  price_cents BIGINT NOT NULL
);

-- wallets
CREATE TABLE IF NOT EXISTS wallets (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id BIGINT UNIQUE NOT NULL,
  balance_cents BIGINT DEFAULT 0,
  pending_cents BIGINT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- wallet transactions ledger
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  wallet_id BIGINT NOT NULL,
  order_id BIGINT NULL,
  type ENUM('credit','debit') NOT NULL,
  amount_cents BIGINT NOT NULL,
  balance_after_cents BIGINT NOT NULL,
  note VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
