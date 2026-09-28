-- ==============================================================================
-- CARRENT PHASE 7: PAYMENT STORAGE, POLICIES & AUTOMATION TRIGGER
-- ==============================================================================

-- 1. Add complementary metadata columns to public.payments
ALTER TABLE public.payments 
    ADD COLUMN IF NOT EXISTS bank_name TEXT,
    ADD COLUMN IF NOT EXISTS account_number TEXT,
    ADD COLUMN IF NOT EXISTS account_holder TEXT,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- 2. Ensure Storage Bucket 'documents' exists for payment proofs
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'documents',
    'documents',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];

-- 3. Storage RLS Policies
DROP POLICY IF EXISTS "Authenticated users upload payment proofs" ON storage.objects;
CREATE POLICY "Authenticated users upload payment proofs"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'documents');

DROP POLICY IF EXISTS "Public view documents bucket" ON storage.objects;
CREATE POLICY "Public view documents bucket"
ON storage.objects FOR SELECT
USING (bucket_id = 'documents');

-- 4. User UPDATE policy for public.payments
DROP POLICY IF EXISTS "Users update own pending payments" ON public.payments;
CREATE POLICY "Users update own pending payments" ON public.payments FOR UPDATE
    USING (EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = payments.booking_id AND b.user_id = auth.uid()) AND status = 'pending')
    WITH CHECK (EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = payments.booking_id AND b.user_id = auth.uid()));

-- 5. Automatic Sync Trigger: Payments -> Bookings
CREATE OR REPLACE FUNCTION public.handle_payment_status_sync()
RETURNS trigger AS $$
BEGIN
    -- If payment is verified/paid, mark booking as paid and confirmed
    IF NEW.status = 'paid' THEN
        UPDATE public.bookings
        SET payment_status = 'paid',
            booking_status = CASE 
                WHEN booking_status = 'pending' THEN 'confirmed'::booking_status 
                ELSE booking_status 
            END,
            updated_at = NOW()
        WHERE id = NEW.booking_id;

    -- If payment proof is uploaded and pending verification
    ELSIF NEW.status = 'pending' AND NEW.payment_proof_url IS NOT NULL THEN
        UPDATE public.bookings
        SET payment_status = 'pending',
            updated_at = NOW()
        WHERE id = NEW.booking_id AND payment_status = 'unpaid';

    -- If payment failed
    ELSIF NEW.status = 'failed' THEN
        UPDATE public.bookings
        SET payment_status = 'failed',
            updated_at = NOW()
        WHERE id = NEW.booking_id;
    END IF;

    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_payment_status_sync ON public.payments;
CREATE TRIGGER on_payment_status_sync
    BEFORE INSERT OR UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.handle_payment_status_sync();
