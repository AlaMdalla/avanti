-- Migration: Create profiles table and related functions
-- Created: 2025-10-14

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  first_name TEXT,
  last_name TEXT,
  pseudo TEXT UNIQUE,
  -- filepath: /home/noya/dev/avanti_mobile/database/migrations/001_create_profiles_table.sql
-- Migration: Create profiles table and related functions
-- Created: 2025-10-14

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  first_name TEXT,
  last_name TEXT,
  pseudo TEXT UNIQUE,
  