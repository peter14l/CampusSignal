-- ==============================================================================
-- Migration: Pan-India Multi-College Discovery & Moderation Hub
-- File: supabase/migrations/20261001_pan_india_multi_college.sql
-- Goal: Multi-college scoping, private internship wall, tiered student ID
--       verification, and passkey-based fest convenor moderation.
-- NOTE: Preserves existing schema.sql without modification.
-- ==============================================================================

-- 1. Create Colleges Master Table
CREATE TABLE IF NOT EXISTS public.colleges (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    short_code TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    logo_url TEXT,
    domain_patterns TEXT[] DEFAULT '{}',
    popular_branches TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for speedy college lookups
CREATE INDEX IF NOT EXISTS idx_colleges_short_code ON public.colleges(short_code);
CREATE INDEX IF NOT EXISTS idx_colleges_city ON public.colleges(city);

-- Enable RLS for Colleges
ALTER TABLE public.colleges ENABLE ROW LEVEL SECURITY;

-- Colleges Read Policy: Publicly readable by all students and guests
CREATE POLICY "Colleges are publicly viewable"
    ON public.colleges FOR SELECT
    USING (true);

-- 2. Seed Initial Curated Indian Universities
INSERT INTO public.colleges (id, name, short_code, city, state, domain_patterns, popular_branches)
VALUES
    ('sxuk', 'St. Xavier''s University, Kolkata', 'SXUK', 'Kolkata', 'West Bengal',
     ARRAY['@sxuk.edu.in', '@sxuk.in'],
     ARRAY['B.Tech in CSE', 'B.Tech in AI & ML', 'B.Tech in ECE', 'B.Sc. in Statistics and Data Science', 'B.Com. (Honours)', 'B.M.S. (Honours)', 'M.Sc. Computer Science', 'LLM. Law']),
    ('ju', 'Jadavpur University', 'JU', 'Kolkata', 'West Bengal',
     ARRAY['@jadavpuruniversity.in', '@jdvu.ac.in'],
     ARRAY['B.E. Computer Science & Engineering', 'B.E. Electronics & Telecommunication', 'B.E. Information Technology', 'B.E. Mechanical Engineering', 'M.C.A.', 'M.Tech Computer Science']),
    ('iitkgp', 'Indian Institute of Technology Kharagpur', 'IITKGP', 'Kharagpur', 'West Bengal',
     ARRAY['@iitkgp.ac.in'],
     ARRAY['B.Tech in Computer Science and Engineering', 'B.Tech in Artificial Intelligence', 'B.Tech in Electronics & Electrical Comm.', 'B.Tech in Mathematics & Computing', 'Dual Degree B.Tech/M.Tech CSE']),
    ('iitb', 'Indian Institute of Technology Bombay', 'IITB', 'Mumbai', 'Maharashtra',
     ARRAY['@iitb.ac.in'],
     ARRAY['B.Tech Computer Science and Engineering', 'B.Tech Electrical Engineering', 'B.Tech Mechanical Engineering', 'M.Tech Computer Science']),
    ('du', 'University of Delhi', 'DU', 'New Delhi', 'Delhi',
     ARRAY['@du.ac.in'],
     ARRAY['B.Sc. (Hons) Computer Science', 'B.A. (Hons) Economics', 'B.Com. (Honours)', 'B.Sc. (Hons) Mathematics', 'M.Sc. Informatics']),
    ('sxc', 'St. Xavier''s College (Autonomous), Kolkata', 'SXC', 'Kolkata', 'West Bengal',
     ARRAY['@sxccal.edu'],
     ARRAY['B.Sc. Computer Science (Honours)', 'B.Com. (Honours)', 'B.Sc. Statistics (Honours)', 'B.Sc. Economics (Honours)', 'B.Sc. Multimedia & Animation']),
    ('christ', 'Christ University', 'CHRIST', 'Bengaluru', 'Karnataka',
     ARRAY['@christuniversity.in'],
     ARRAY['B.Tech Computer Science & Engineering', 'B.C.A.', 'B.B.A. (Honours)', 'B.Sc. Data Science']),
    ('bits', 'BITS Pilani', 'BITS', 'Pilani', 'Rajasthan',
     ARRAY['@pilani.bits-pilani.ac.in'],
     ARRAY['B.E. Computer Science', 'B.E. Electrical & Electronics', 'M.Sc. Mathematics', 'M.Sc. Economics']),
    ('nitdgp', 'National Institute of Technology Durgapur', 'NITDGP', 'Durgapur', 'West Bengal',
     ARRAY['@nitdgp.ac.in'],
     ARRAY['B.Tech Computer Science and Engineering', 'B.Tech Electronics & Comm. Engineering', 'B.Tech Information Technology', 'M.C.A.'])
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    short_code = EXCLUDED.short_code,
    city = EXCLUDED.city,
    state = EXCLUDED.state,
    domain_patterns = EXCLUDED.domain_patterns,
    popular_branches = EXCLUDED.popular_branches;

-- 3. Extend Events Table for Pan-India Scoping and Moderation
ALTER TABLE public.events
    ADD COLUMN IF NOT EXISTS college_id TEXT DEFAULT 'sxuk' REFERENCES public.colleges(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS college_name TEXT DEFAULT 'St. Xavier''s University, Kolkata',
    ADD COLUMN IF NOT EXISTS college_short_code TEXT DEFAULT 'SXUK',
    ADD COLUMN IF NOT EXISTS college_logo_url TEXT,
    ADD COLUMN IF NOT EXISTS scope TEXT DEFAULT 'intraCollege' CHECK (scope IN ('intraCollege', 'interCollege')),
    ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'published' CHECK (moderation_status IN ('draft', 'pendingApproval', 'published', 'rejected')),
    ADD COLUMN IF NOT EXISTS fest_id TEXT,
    ADD COLUMN IF NOT EXISTS fest_name TEXT,
    ADD COLUMN IF NOT EXISTS approved_by TEXT,
    ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

CREATE INDEX IF NOT EXISTS idx_events_college_id ON public.events(college_id);
CREATE INDEX IF NOT EXISTS idx_events_scope ON public.events(scope);
CREATE INDEX IF NOT EXISTS idx_events_moderation_status ON public.events(moderation_status);
CREATE INDEX IF NOT EXISTS idx_events_fest_id ON public.events(fest_id);

-- 4. Extend Profiles Table for Multi-College and Roles
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS college_id TEXT DEFAULT 'sxuk' REFERENCES public.colleges(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS college_name TEXT DEFAULT 'St. Xavier''s University, Kolkata',
    ADD COLUMN IF NOT EXISTS college_short_code TEXT DEFAULT 'SXUK',
    ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'student' CHECK (role IN ('student', 'clubLead', 'festAdmin', 'faculty', 'superAdmin')),
    ADD COLUMN IF NOT EXISTS is_verified_student BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS roll_number TEXT,
    ADD COLUMN IF NOT EXISTS managed_fest_ids TEXT[] DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS managed_club_ids TEXT[] DEFAULT '{}';

CREATE INDEX IF NOT EXISTS idx_profiles_college_id ON public.profiles(college_id);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- 5. Row-Level Security: Private Internship Wall Enforcement
-- 5. Row-Level Security: Private Internship Wall Enforcement
-- Drop older public select if exists to replace with scope-aware policy
DROP POLICY IF EXISTS "Published events are viewable by everyone" ON public.events;
DROP POLICY IF EXISTS "Public can view published events" ON public.events;
DROP POLICY IF EXISTS "Events multi college scope and internship wall" ON public.events;
DROP POLICY IF EXISTS "Moderators can view pending events" ON public.events;
DROP POLICY IF EXISTS "Moderators can update event moderation" ON public.events;

CREATE POLICY "Events multi college scope and internship wall"
    ON public.events FOR SELECT
    USING (
        -- Moderation constraint: Only published events are visible to general audience
        moderation_status = 'published'
        AND (
            -- RULE A: Private Internship Wall
            -- Any internship or placement drive can ONLY be seen if the student belongs to the host college
            CASE
                WHEN (category ILIKE '%intern%' OR category ILIKE '%placement%') THEN
                    (college_id = (SELECT college_id FROM public.profiles WHERE profiles.id = auth.uid()))
                -- RULE B: Inter-College events are open Pan-India
                WHEN scope = 'interCollege' THEN
                    true
                -- RULE C: Intra-College events visible only to the hosting college
                ELSE
                    (college_id = (SELECT college_id FROM public.profiles WHERE profiles.id = auth.uid()))
            END
        )
    );

-- Privileged Moderation Policy: Admins, Faculty, and Fest Convenors can view pending events
CREATE POLICY "Moderators can view pending events"
    ON public.events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid()
            AND (
                p.role IN ('faculty', 'superAdmin')
                OR (p.role = 'festAdmin' AND events.fest_id = ANY(p.managed_fest_ids))
                OR (p.college_id = events.college_id AND p.role IN ('faculty', 'clubLead'))
            )
        )
    );

-- Moderators can update event moderation status (approve / reject / promote)
CREATE POLICY "Moderators can update event moderation"
    ON public.events FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid()
            AND (
                p.role IN ('faculty', 'superAdmin')
                OR (p.role = 'festAdmin' AND events.fest_id = ANY(p.managed_fest_ids))
                OR (p.college_id = events.college_id AND p.role IN ('faculty', 'clubLead'))
            )
        )
    );
