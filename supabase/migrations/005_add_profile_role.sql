-- Migration: Add role enum and column to profiles
-- Creates user_role enum (admin, user) and adds column with default 'user'

DO $$ BEGIN
  CREATE TYPE public.user_role AS ENUM ('admin', 'user');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS role public.user_role NOT NULL DEFAULT 'user';

-- Index for quick filtering by role
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
