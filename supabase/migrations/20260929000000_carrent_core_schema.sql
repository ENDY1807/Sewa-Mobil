-- ==============================================================================
-- CARRENT ENTERPRISE SUPABASE DATABASE ARCHITECTURE & SCHEMA MIGRATION
-- Production-Ready Schema with Strict RLS, Integrity Constraints & RPCs
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Custom Enumeration Types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('user', 'staff', 'admin');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE car_status AS ENUM ('available', 'rented', 'maintenance', 'inactive');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE availability_status AS ENUM ('available', 'reserved', 'unavailable');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'ongoing', 'completed', 'cancelled', 'rejected');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('unpaid', 'pending', 'paid', 'failed', 'refunded');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE discount_type AS ENUM ('percentage', 'fixed');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 3. PROFILES TABLE (Linked with auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL DEFAULT '',
    phone TEXT,
    avatar_url TEXT,
    role user_role NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. BRANDS TABLE
CREATE TABLE IF NOT EXISTS public.brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    logo_url TEXT,
    country TEXT,
    description TEXT,
    website_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. LOCATIONS TABLE
CREATE TABLE IF NOT EXISTS public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    province TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. CARS TABLE (Scalable Vehicle Catalog with Legal Attribution)
CREATE TABLE IF NOT EXISTS public.cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES public.brands(id) ON DELETE RESTRICT,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    location_id UUID REFERENCES public.locations(id) ON DELETE SET NULL,
    model TEXT NOT NULL,
    variant TEXT,
    year INTEGER NOT NULL CHECK (year >= 1990 AND year <= EXTRACT(YEAR FROM NOW()) + 2),
    description TEXT,
    transmission TEXT NOT NULL CHECK (transmission IN ('Manual', 'Otomatis', 'CVT', 'Dual-Clutch')),
    fuel_type TEXT NOT NULL CHECK (fuel_type IN ('Bensin', 'Diesel', 'Hybrid', 'Electric', 'PHEV')),
    seats INTEGER NOT NULL CHECK (seats > 0 AND seats <= 20),
    doors INTEGER NOT NULL DEFAULT 4 CHECK (doors >= 2 AND doors <= 6),
    color TEXT,
    engine TEXT,
    power TEXT,
    daily_price NUMERIC(12, 2) NOT NULL CHECK (daily_price > 0),
    weekly_price NUMERIC(12, 2) CHECK (weekly_price > 0),
    monthly_price NUMERIC(12, 2) CHECK (monthly_price > 0),
    deposit NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (deposit >= 0),
    status car_status NOT NULL DEFAULT 'available',
    availability_status availability_status NOT NULL DEFAULT 'available',
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    rating NUMERIC(3, 2) NOT NULL DEFAULT 5.0 CHECK (rating >= 1.0 AND rating <= 5.0),
    total_reviews INTEGER NOT NULL DEFAULT 0 CHECK (total_reviews >= 0),
    is_demo BOOLEAN NOT NULL DEFAULT TRUE,
    source_name TEXT DEFAULT 'Direct Partner Fleet',
    source_url TEXT,
    source_id TEXT,
    license TEXT DEFAULT 'Proprietary / Authorized Fleet Agreement',
    attribution TEXT DEFAULT 'CarRent Authorized Vehicle Fleet',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. CAR IMAGES TABLE
CREATE TABLE IF NOT EXISTS public.car_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    alt_text TEXT,
    category TEXT NOT NULL DEFAULT 'exterior' CHECK (category IN ('exterior', 'interior', 'dashboard', 'gallery')),
    sort_order INTEGER NOT NULL DEFAULT 0,
    source_url TEXT,
    license TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. CAR FEATURES TABLE
CREATE TABLE IF NOT EXISTS public.car_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE CASCADE,
    feature_name TEXT NOT NULL,
    icon_name TEXT,
    UNIQUE(car_id, feature_name)
);

-- 10. PROMOTIONS TABLE
CREATE TABLE IF NOT EXISTS public.promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    discount_type discount_type NOT NULL DEFAULT 'percentage',
    discount_value NUMERIC(10, 2) NOT NULL CHECK (discount_value > 0),
    minimum_rental_days INTEGER NOT NULL DEFAULT 1,
    minimum_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    max_discount NUMERIC(12, 2),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    usage_limit INTEGER,
    times_used INTEGER NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE RESTRICT,
    pickup_location_id UUID NOT NULL REFERENCES public.locations(id) ON DELETE RESTRICT,
    dropoff_location_id UUID NOT NULL REFERENCES public.locations(id) ON DELETE RESTRICT,
    pickup_date TIMESTAMPTZ NOT NULL,
    return_date TIMESTAMPTZ NOT NULL,
    rental_days INTEGER NOT NULL CHECK (rental_days >= 1),
    daily_price NUMERIC(12, 2) NOT NULL CHECK (daily_price > 0),
    subtotal NUMERIC(12, 2) NOT NULL CHECK (subtotal > 0),
    discount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (discount >= 0),
    deposit NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (deposit >= 0),
    total_price NUMERIC(12, 2) NOT NULL CHECK (total_price >= 0),
    payment_status payment_status NOT NULL DEFAULT 'unpaid',
    booking_status booking_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_dates CHECK (return_date > pickup_date)
);

-- 12. PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL DEFAULT 'bank_transfer',
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    payment_proof_url TEXT,
    status payment_status NOT NULL DEFAULT 'pending',
    transaction_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE REFERENCES public.bookings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. FAVORITES TABLE
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, car_id)
);

-- 15. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'booking',
    reference_id TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. AUDIT LOGS TABLE
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR HIGH QUERY PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_cars_status ON public.cars(status, availability_status);
CREATE INDEX IF NOT EXISTS idx_cars_brand ON public.cars(brand_id);
CREATE INDEX IF NOT EXISTS idx_cars_category ON public.cars(category_id);
CREATE INDEX IF NOT EXISTS idx_cars_daily_price ON public.cars(daily_price);
CREATE INDEX IF NOT EXISTS idx_cars_featured ON public.cars(featured);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_car_dates ON public.bookings(car_id, pickup_date, return_date);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(booking_status);
CREATE INDEX IF NOT EXISTS idx_car_images_car ON public.car_images(car_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs(actor_id, action);

-- ==============================================================================
-- DATABASE HELPER FUNCTIONS & TRIGGERS
-- ==============================================================================

-- Helper: Retrieve Current User Role
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT AS $$
    SELECT role::TEXT FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Trigger: Automatically Create Profile on Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
        'user'
    )
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Availability Engine RPC: Checks for overlapping active bookings
CREATE OR REPLACE FUNCTION public.check_car_availability(
    p_car_id UUID,
    p_pickup_date TIMESTAMPTZ,
    p_return_date TIMESTAMPTZ
)
RETURNS BOOLEAN AS $$
DECLARE
    v_conflict_count INTEGER;
BEGIN
    IF p_return_date <= p_pickup_date THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*)
    INTO v_conflict_count
    FROM public.bookings
    WHERE car_id = p_car_id
      AND booking_status IN ('confirmed', 'ongoing', 'pending')
      AND NOT (return_date <= p_pickup_date OR pickup_date >= p_return_date);

    RETURN (v_conflict_count = 0);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Server-Side Price Calculation RPC
CREATE OR REPLACE FUNCTION public.calculate_booking_price(
    p_car_id UUID,
    p_pickup_date TIMESTAMPTZ,
    p_return_date TIMESTAMPTZ,
    p_promo_code TEXT DEFAULT NULL
)
RETURNS TABLE (
    rental_days INTEGER,
    daily_price NUMERIC,
    subtotal NUMERIC,
    discount NUMERIC,
    deposit NUMERIC,
    total_price NUMERIC
) AS $$
DECLARE
    v_daily_price NUMERIC;
    v_deposit NUMERIC;
    v_days INTEGER;
    v_subtotal NUMERIC;
    v_discount NUMERIC := 0;
    v_promo RECORD;
BEGIN
    IF p_return_date <= p_pickup_date THEN
        RAISE EXCEPTION 'Return date must be strictly after pickup date';
    END IF;

    -- Calculate days (at least 1 day)
    v_days := GREATEST(1, CEIL(EXTRACT(EPOCH FROM (p_return_date - p_pickup_date)) / 86400));

    SELECT c.daily_price, c.deposit
    INTO v_daily_price, v_deposit
    FROM public.cars c
    WHERE c.id = p_car_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Car with ID % not found', p_car_id;
    END IF;

    v_subtotal := v_days * v_daily_price;

    -- Validate Promo Code if provided
    IF p_promo_code IS NOT NULL AND TRIM(p_promo_code) <> '' THEN
        SELECT * INTO v_promo
        FROM public.promotions
        WHERE code = UPPER(TRIM(p_promo_code))
          AND active = TRUE
          AND NOW() BETWEEN start_date AND end_date
          AND v_days >= minimum_rental_days
          AND v_subtotal >= minimum_price
          AND (usage_limit IS NULL OR times_used < usage_limit);

        IF FOUND THEN
            IF v_promo.discount_type = 'percentage' THEN
                v_discount := (v_subtotal * (v_promo.discount_value / 100.0));
                IF v_promo.max_discount IS NOT NULL AND v_discount > v_promo.max_discount THEN
                    v_discount := v_promo.max_discount;
                END IF;
            ELSE
                v_discount := LEAST(v_promo.discount_value, v_subtotal);
            END IF;
        END IF;
    END IF;

    rental_days := v_days;
    daily_price := v_daily_price;
    subtotal := v_subtotal;
    discount := v_discount;
    deposit := v_deposit;
    total_price := (v_subtotal - v_discount) + v_deposit;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- PROFILES RLS
CREATE POLICY "Public profiles can be viewed by anyone"
    ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- BRANDS & CATEGORIES RLS
CREATE POLICY "Brands public read" ON public.brands FOR SELECT USING (true);
CREATE POLICY "Brands admin manage" ON public.brands FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

CREATE POLICY "Categories public read" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Categories admin manage" ON public.categories FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

-- LOCATIONS RLS
CREATE POLICY "Locations public read" ON public.locations FOR SELECT USING (active = true OR public.current_user_role() IN ('admin', 'staff'));
CREATE POLICY "Locations admin manage" ON public.locations FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

-- CARS & IMAGES RLS
CREATE POLICY "Cars public read active" ON public.cars FOR SELECT
    USING (status != 'inactive' OR public.current_user_role() IN ('admin', 'staff'));
CREATE POLICY "Cars admin manage" ON public.cars FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

CREATE POLICY "Car images public read" ON public.car_images FOR SELECT USING (true);
CREATE POLICY "Car images admin manage" ON public.car_images FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

CREATE POLICY "Car features public read" ON public.car_features FOR SELECT USING (true);
CREATE POLICY "Car features admin manage" ON public.car_features FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

-- PROMOTIONS RLS
CREATE POLICY "Promotions active view" ON public.promotions FOR SELECT
    USING (active = true OR public.current_user_role() IN ('admin', 'staff'));
CREATE POLICY "Promotions admin manage" ON public.promotions FOR ALL
    USING (public.current_user_role() IN ('admin', 'staff'));

-- BOOKINGS RLS
CREATE POLICY "Users view own bookings" ON public.bookings FOR SELECT
    USING (auth.uid() = user_id OR public.current_user_role() IN ('admin', 'staff'));
CREATE POLICY "Users create own bookings" ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admin update bookings" ON public.bookings FOR UPDATE
    USING (public.current_user_role() IN ('admin', 'staff'));

-- PAYMENTS RLS
CREATE POLICY "Users view own payments" ON public.payments FOR SELECT
    USING (EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = payments.booking_id AND b.user_id = auth.uid()) OR public.current_user_role() IN ('admin', 'staff'));
CREATE POLICY "Users upload payment proof" ON public.payments FOR INSERT
    WITH CHECK (EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = booking_id AND b.user_id = auth.uid()));
CREATE POLICY "Admin manage payments" ON public.payments FOR UPDATE
    USING (public.current_user_role() IN ('admin', 'staff'));

-- REVIEWS RLS
CREATE POLICY "Reviews public read" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users submit review for completed booking" ON public.reviews FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.id = booking_id
              AND b.user_id = auth.uid()
              AND b.booking_status = 'completed'
        )
    );

-- FAVORITES RLS
CREATE POLICY "Users manage own favorites" ON public.favorites FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- NOTIFICATIONS RLS
CREATE POLICY "Users view own notifications" ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);
CREATE POLICY "Users mark notifications read" ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- AUDIT LOGS RLS
CREATE POLICY "Admin view audit logs" ON public.audit_logs FOR SELECT
    USING (public.current_user_role() IN ('admin', 'staff'));
CREATE POLICY "System insert audit logs" ON public.audit_logs FOR INSERT
    WITH CHECK (true);
