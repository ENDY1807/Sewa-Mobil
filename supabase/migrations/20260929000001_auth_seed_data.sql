-- ==============================================================================
-- CARRENT AUTHENTICATION SEED & ROLE PROMOTION UTILITIES
-- ==============================================================================

-- 1. Stored Procedure: Promote any registered email to 'admin' or 'staff'
CREATE OR REPLACE FUNCTION public.promote_user_role(
    p_email TEXT,
    p_role user_role
)
RETURNS VOID AS $$
BEGIN
    UPDATE public.profiles
    SET role = p_role,
        updated_at = NOW()
    WHERE email = LOWER(TRIM(p_email));

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User with email % was not found in public.profiles. Ensure the user has registered first.', p_email;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Convenience function to make your account Super Admin
-- Run this in Supabase SQL Editor with your registered email:
-- SELECT public.promote_user_role('endy@carrent.app', 'admin');
