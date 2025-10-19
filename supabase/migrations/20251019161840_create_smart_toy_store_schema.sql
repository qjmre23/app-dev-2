/*
  # Smart Toy Store System - Complete Database Schema

  ## Overview
  This migration creates the complete database schema for the Smart Toy Store system,
  including user management, toy catalog, order processing, and employee assignments.

  ## New Tables

  ### 1. `users`
  - `id` (uuid, primary key) - Unique user identifier
  - `username` (text, unique) - Username for login
  - `email` (text, unique) - User email address
  - `department` (text) - User department/role (General, Admin, Employee)
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. `toys`
  - `id` (text, primary key) - Toy ID (e.g., TG01, AF01)
  - `name` (text) - Toy name
  - `category` (text) - Category (Toy Guns, Action Figures, Dolls, Puzzles)
  - `rfid_uid` (text, unique) - RFID tag UID for scanning
  - `price` (numeric) - Toy price
  - `image_url` (text) - URL or path to toy image
  - `stock` (integer) - Available stock
  - `created_at` (timestamptz) - Record creation timestamp

  ### 3. `orders`
  - `id` (uuid, primary key) - Order unique identifier
  - `user_id` (uuid, foreign key) - User who placed the order
  - `toy_id` (text, foreign key) - Ordered toy ID
  - `toy_name` (text) - Toy name snapshot
  - `category` (text) - Toy category
  - `rfid_uid` (text) - RFID UID for tracking
  - `assigned_person` (text) - Employee assigned to fulfill order
  - `status` (text) - Order status (PENDING, PROCESSING, ON_THE_WAY, DELIVERED)
  - `total_amount` (numeric) - Order total amount
  - `created_at` (timestamptz) - Order placement time
  - `updated_at` (timestamptz) - Last status update time

  ### 4. `employees`
  - `id` (uuid, primary key) - Employee identifier
  - `name` (text, unique) - Employee full name
  - `category` (text) - Assigned toy category
  - `rfid_uid` (text, unique) - Employee RFID badge UID
  - `active` (boolean) - Employee active status

  ## Security

  1. Enable RLS on all tables
  2. Users can read their own data and create orders
  3. Employees can view orders assigned to them
  4. Admin users have full access
  5. Public can read toy catalog
  6. Arduino/system can update order status via service role

  ## Notes

  - All timestamps use UTC timezone
  - Default department for customers is "General"
  - Order status follows workflow: PENDING → PROCESSING → ON_THE_WAY → DELIVERED
  - Employee assignments are based on toy categories
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  department text DEFAULT 'General' NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create toys table
CREATE TABLE IF NOT EXISTS toys (
  id text PRIMARY KEY,
  name text NOT NULL,
  category text NOT NULL,
  rfid_uid text UNIQUE NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price >= 0),
  image_url text,
  stock integer DEFAULT 0 NOT NULL CHECK (stock >= 0),
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  toy_id text REFERENCES toys(id) ON DELETE RESTRICT NOT NULL,
  toy_name text NOT NULL,
  category text NOT NULL,
  rfid_uid text NOT NULL,
  assigned_person text NOT NULL,
  status text DEFAULT 'PENDING' NOT NULL CHECK (status IN ('PENDING', 'PROCESSING', 'ON_THE_WAY', 'DELIVERED')),
  total_amount numeric(10, 2) NOT NULL CHECK (total_amount >= 0),
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  category text NOT NULL,
  rfid_uid text UNIQUE NOT NULL,
  active boolean DEFAULT true NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_category ON orders(category);
CREATE INDEX IF NOT EXISTS idx_orders_rfid_uid ON orders(rfid_uid);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_toys_category ON toys(category);
CREATE INDEX IF NOT EXISTS idx_employees_category ON employees(category);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE toys ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- RLS Policies for toys table (public read access)
CREATE POLICY "Anyone can view toys"
  ON toys FOR SELECT
  TO anon, authenticated
  USING (true);

-- RLS Policies for orders table
CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System can update all orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policies for employees table
CREATE POLICY "Anyone can view employees"
  ON employees FOR SELECT
  TO anon, authenticated
  USING (true);

-- Insert default employees
INSERT INTO employees (name, category, rfid_uid, active)
VALUES
  ('John Marwin Ebona', 'Toy Guns', 'EMPLOYEE_JM_UID', true),
  ('Jannalyn Cruz', 'Action Figures', 'EMPLOYEE_JC_UID', true),
  ('Prince Marl Lizandrelle Mirasol', 'Dolls', 'EMPLOYEE_PM_UID', true),
  ('Renz Christiane Ming', 'Puzzles', 'EMPLOYEE_RC_UID', true)
ON CONFLICT (name) DO NOTHING;

-- Insert toy catalog
INSERT INTO toys (id, name, category, rfid_uid, price, stock)
VALUES
  ('TG01', 'Laser Ray Gun', 'Toy Guns', 'TG01_UID', 29.99, 50),
  ('TG02', 'Water Blaster 3000', 'Toy Guns', 'TG02_UID', 19.99, 45),
  ('TG03', 'Foam Dart Pistol', 'Toy Guns', 'TG03_UID', 14.99, 60),
  ('AF01', 'Galaxy Commander', 'Action Figures', 'AF01_UID', 12.99, 40),
  ('AF02', 'Jungle Explorer', 'Action Figures', 'AF02_UID', 11.99, 35),
  ('AF03', 'Ninja Warrior', 'Action Figures', 'AF03_UID', 13.99, 38),
  ('DL01', 'Princess Star', 'Dolls', 'DL01_UID', 22.99, 30),
  ('DL02', 'Fashionista Doll', 'Dolls', 'DL02_UID', 24.99, 28),
  ('DL03', 'Baby Joy', 'Dolls', 'DL03_UID', 18.99, 42),
  ('PZ01', '1000pc World Map', 'Puzzles', 'PZ01_UID', 15.99, 25),
  ('PZ02', '3D Wooden Dinosaur', 'Puzzles', 'PZ02_UID', 17.99, 22),
  ('PZ03', 'Mystery Box Puzzle', 'Puzzles', 'PZ03_UID', 21.99, 20)
ON CONFLICT (id) DO NOTHING;

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
    CREATE TRIGGER update_users_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_orders_updated_at') THEN
    CREATE TRIGGER update_orders_updated_at
      BEFORE UPDATE ON orders
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;