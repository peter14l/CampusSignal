-- ==============================================================================
-- Migration: Fix UUID = TEXT Comparison in RLS Policies
-- File: supabase/migrations/20261001_fix_uuid_type_cast_rls.sql
-- Goal: Fix PostgreSQL 42883 error by comparing public.profiles.id (UUID)
--       directly with auth.uid() (UUID) without invalid ::text cast.
-- ==============================================================================

-- Drop existing / conflicting policies
DROP POLICY IF EXISTS "Published events are viewable by everyone" ON public.events;
DROP POLICY IF EXISTS "Public can view published events" ON public.events;
DROP POLICY IF EXISTS "Events multi college scope and internship wall" ON public.events;
DROP POLICY IF EXISTS "Moderators can view pending events" ON public.events;
DROP POLICY IF EXISTS "Moderators can update event moderation" ON public.events;

-- 1. Scope-Aware Feed & Private Internship Wall
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

-- 2. Privileged Moderation Policy: Admins, Faculty, and Fest Convenors can view pending events
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

-- 3. Moderators can update event moderation status (approve / reject / promote)
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
