-- ==============================================================================
-- Migration: Dean-Approved Student Photo ID Card Verification & Governance
-- File: supabase/migrations/20261013_student_id_card_verification.sql
-- Goal: Spotify/SheerID & GitHub Education style student verification with
--       DPDP 2023 compliance, anti-fraud uniqueness, and academic expiration.
-- NOTE: Preserves existing schema.sql and previous migrations without modification.
-- ==============================================================================

-- 1. Extend Profiles Table for Verification Status & Expiry
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'unverified' 
        CHECK (verification_status IN ('unverified', 'pending', 'approved', 'rejected', 'expired')),
    ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS verification_expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS id_card_front_url TEXT,
    ADD COLUMN IF NOT EXISTS verification_rejection_reason TEXT,
    ADD COLUMN IF NOT EXISTS active_verification_id UUID;

CREATE INDEX IF NOT EXISTS idx_profiles_verification_status ON public.profiles(verification_status);
CREATE INDEX IF NOT EXISTS idx_profiles_verification_expires_at ON public.profiles(verification_expires_at);

-- 2. Create Student Verifications Table
CREATE TABLE IF NOT EXISTS public.student_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    college_id TEXT NOT NULL REFERENCES public.colleges(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL DEFAULT 'college_id_card' 
        CHECK (document_type IN ('college_id_card', 'fee_receipt', 'bonafide_certificate', 'library_card')),
    full_name_on_card TEXT NOT NULL,
    roll_number TEXT NOT NULL,
    department TEXT,
    academic_year TEXT,
    id_card_front_url TEXT NOT NULL,
    id_card_back_url TEXT,
    storage_path TEXT,
    status TEXT NOT NULL DEFAULT 'pending' 
        CHECK (status IN ('pending', 'approved', 'rejected', 'expired')),
    verification_method TEXT NOT NULL DEFAULT 'automated_ocr' 
        CHECK (verification_method IN ('automated_ocr', 'manual_faculty', 'hybrid')),
    ocr_confidence NUMERIC(4,3) DEFAULT 0.000,
    ocr_raw_payload JSONB DEFAULT '{}'::jsonb,
    ocr_college_matched BOOLEAN DEFAULT FALSE,
    ocr_name_matched BOOLEAN DEFAULT FALSE,
    ocr_extracted_roll TEXT,
    ocr_extracted_college TEXT,
    rejection_reason TEXT,
    rejection_code TEXT CHECK (rejection_code IS NULL OR rejection_code IN (
        'blurry_unreadable', 'wrong_college', 'name_mismatch', 'expired_card', 
        'duplicate_roll_number', 'tampered_image', 'other'
    )),
    reviewer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    reviewer_notes TEXT,
    reviewed_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    reverification_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Anti-Fraud Rule: A single roll number at a college can only be actively verified once
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_active_roll_per_college 
    ON public.student_verifications (college_id, roll_number) 
    WHERE (status = 'approved');

CREATE INDEX IF NOT EXISTS idx_student_verifications_user_id ON public.student_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_student_verifications_college_id ON public.student_verifications(college_id);
CREATE INDEX IF NOT EXISTS idx_student_verifications_status ON public.student_verifications(status);
CREATE INDEX IF NOT EXISTS idx_student_verifications_department ON public.student_verifications(department);

-- 3. Row-Level Security (RLS) for Student Verifications
ALTER TABLE public.student_verifications ENABLE ROW LEVEL SECURITY;

-- Students can read their own verification submissions
CREATE POLICY "Students can view own verifications"
    ON public.student_verifications FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Students can submit verification requests for their own account
CREATE POLICY "Students can insert own verifications"
    ON public.student_verifications FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Campus Admins / Faculty can view verifications for their college
CREATE POLICY "Faculty can view college verifications"
    ON public.student_verifications FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid()
            AND (
                p.role IN ('superAdmin')
                OR (p.college_id = student_verifications.college_id AND p.role IN ('faculty', 'clubLead'))
            )
        )
    );

-- Faculty can update verification status (approve / reject)
CREATE POLICY "Faculty can update college verifications"
    ON public.student_verifications FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid()
            AND (
                p.role IN ('superAdmin')
                OR (p.college_id = student_verifications.college_id AND p.role = 'faculty')
            )
        )
    );

-- 4. Automated Status Synchronization Trigger
CREATE OR REPLACE FUNCTION public.handle_student_verification_sync()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' THEN
        UPDATE public.profiles
        SET is_verified_student = TRUE,
            verification_status = 'approved',
            roll_number = NEW.roll_number,
            college_id = NEW.college_id,
            verified_at = COALESCE(NEW.verified_at, NOW()),
            verification_expires_at = COALESCE(NEW.expires_at, NOW() + INTERVAL '365 days'),
            id_card_front_url = NEW.id_card_front_url,
            active_verification_id = NEW.id,
            verification_rejection_reason = NULL,
            updated_at = NOW()
        WHERE id = NEW.user_id;

    ELSIF NEW.status = 'rejected' THEN
        UPDATE public.profiles
        SET is_verified_student = FALSE,
            verification_status = 'rejected',
            verification_rejection_reason = NEW.rejection_reason,
            updated_at = NOW()
        WHERE id = NEW.user_id;

    ELSIF NEW.status = 'expired' THEN
        UPDATE public.profiles
        SET is_verified_student = FALSE,
            verification_status = 'expired',
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_student_verification ON public.student_verifications;
CREATE TRIGGER trg_sync_student_verification
    AFTER INSERT OR UPDATE OF status ON public.student_verifications
    FOR EACH ROW EXECUTE FUNCTION public.handle_student_verification_sync();

-- 5. Stored Function for Periodic Expiration Sweep
CREATE OR REPLACE FUNCTION public.check_expired_verifications()
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    WITH expired_rows AS (
        UPDATE public.student_verifications
        SET status = 'expired',
            updated_at = NOW()
        WHERE status = 'approved'
          AND expires_at IS NOT NULL
          AND expires_at < NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_count FROM expired_rows;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
