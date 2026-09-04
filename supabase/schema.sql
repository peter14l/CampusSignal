-- ==========================================================
-- CampusSignal Supabase Database Schema
-- Version: 1.0 (Production / Cloud-ready)
-- ==========================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ----------------------------------------------------------
-- 1. Profiles Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    college_email TEXT UNIQUE,
    branch TEXT,
    year INT,
    interests TEXT[] DEFAULT '{}'::TEXT[],
    skills TEXT[] DEFAULT '{}'::TEXT[],
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS: Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by authenticated users"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- ----------------------------------------------------------
-- 2. Clubs Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    logo_r2_key TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clubs are viewable by everyone"
    ON public.clubs FOR SELECT
    USING (true);

-- ----------------------------------------------------------
-- 3. Events Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    category TEXT NOT NULL DEFAULT 'hackathon', -- hackathon | internship | workshop | fest | seminar | club | networking | sports
    organizer_name TEXT NOT NULL,
    organizer_club_id UUID REFERENCES public.clubs(id) ON DELETE SET NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    deadline_at TIMESTAMPTZ,
    venue TEXT NOT NULL DEFAULT 'Main Campus',
    format TEXT NOT NULL DEFAULT 'in_person', -- online | in_person | hybrid
    eligibility_text TEXT,
    eligibility_years INT[] DEFAULT '{}'::INT[],
    eligibility_branches TEXT[] DEFAULT '{}'::TEXT[],
    team_size_text TEXT,
    apply_url TEXT,
    source_url TEXT,
    poster_r2_key TEXT,
    status TEXT NOT NULL DEFAULT 'published', -- draft | published | archived
    metadata JSONB DEFAULT '{}'::jsonb,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published events are viewable by everyone"
    ON public.events FOR SELECT
    USING (status = 'published');

-- Search index on title and description
CREATE INDEX IF NOT EXISTS events_title_trgm_idx ON public.events USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS events_description_trgm_idx ON public.events USING gin (description gin_trgm_ops);
CREATE INDEX IF NOT EXISTS events_starts_at_idx ON public.events (starts_at);
CREATE INDEX IF NOT EXISTS events_category_idx ON public.events (category);

-- ----------------------------------------------------------
-- 4. Event Tags Table (for skill/interest matching)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.event_tags (
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    tag TEXT NOT NULL,
    PRIMARY KEY (event_id, tag)
);

ALTER TABLE public.event_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Event tags are viewable by everyone"
    ON public.event_tags FOR SELECT
    USING (true);

CREATE INDEX IF NOT EXISTS event_tags_tag_idx ON public.event_tags (tag);

-- ----------------------------------------------------------
-- 5. Saves Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.saves (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (user_id, event_id)
);

ALTER TABLE public.saves ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own saves"
    ON public.saves FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------
-- 6. Reminders Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    remind_at TIMESTAMPTZ NOT NULL,
    fired BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own reminders"
    ON public.reminders FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------
-- 7. Applications Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.applications (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    applied_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (user_id, event_id)
);

ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own applications"
    ON public.applications FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------
-- 8. Notifications Table
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- reminder | deadline_soon | new_match | system
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view and update own notifications"
    ON public.notifications FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------
-- 9. Auto-create Profile on Auth Signup Trigger
-- ----------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, college_email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------
-- 10. Personalized Feed Ranking RPC Function
-- ----------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_ranked_feed(
    p_user_id UUID DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_limit INT DEFAULT 20,
    p_offset INT DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    category TEXT,
    organizer_name TEXT,
    organizer_club_id UUID,
    starts_at TIMESTAMPTZ,
    ends_at TIMESTAMPTZ,
    deadline_at TIMESTAMPTZ,
    venue TEXT,
    format TEXT,
    eligibility_text TEXT,
    eligibility_years INT[],
    eligibility_branches TEXT[],
    team_size_text TEXT,
    apply_url TEXT,
    source_url TEXT,
    poster_r2_key TEXT,
    status TEXT,
    metadata JSONB,
    match_score INT,
    matched_tags TEXT[]
) AS $$
DECLARE
    v_interests TEXT[] := '{}';
    v_skills TEXT[] := '{}';
    v_branch TEXT := NULL;
    v_year INT := NULL;
BEGIN
    -- If user_id provided, fetch profile interests
    IF p_user_id IS NOT NULL THEN
        SELECT p.interests, p.skills, p.branch, p.year
        INTO v_interests, v_skills, v_branch, v_year
        FROM public.profiles p
        WHERE p.id = p_user_id;
    END IF;

    RETURN QUERY
    WITH event_matches AS (
        SELECT 
            e.id AS e_id,
            COALESCE(array_agg(t.tag) FILTER (WHERE t.tag = ANY(v_interests || v_skills)), '{}'::TEXT[]) AS matched_tags_arr,
            (
                -- Interest / Skill tag matches (+3 points each)
                COALESCE(COUNT(t.tag) FILTER (WHERE t.tag = ANY(v_interests || v_skills)) * 3, 0) +
                -- Branch match (+2 points)
                CASE WHEN v_branch IS NOT NULL AND (cardinality(e.eligibility_branches) = 0 OR v_branch = ANY(e.eligibility_branches)) THEN 2 ELSE 0 END +
                -- Year match (+2 points)
                CASE WHEN v_year IS NOT NULL AND (cardinality(e.eligibility_years) = 0 OR v_year = ANY(e.eligibility_years)) THEN 2 ELSE 0 END +
                -- Upcoming deadline urgency (+1 to 3 points)
                CASE 
                    WHEN e.deadline_at IS NOT NULL AND e.deadline_at > now() AND e.deadline_at < now() + INTERVAL '3 days' THEN 3
                    WHEN e.deadline_at IS NOT NULL AND e.deadline_at > now() AND e.deadline_at < now() + INTERVAL '7 days' THEN 1
                    ELSE 0 
                END
            )::INT AS score
        FROM public.events e
        LEFT JOIN public.event_tags t ON e.id = t.event_id
        WHERE e.status = 'published'
          AND (p_category IS NULL OR p_category = 'all' OR e.category = p_category)
          AND e.ends_at >= now() - INTERVAL '1 day'
        GROUP BY e.id
    )
    SELECT 
        e.id,
        e.title,
        e.description,
        e.category,
        e.organizer_name,
        e.organizer_club_id,
        e.starts_at,
        e.ends_at,
        e.deadline_at,
        e.venue,
        e.format,
        e.eligibility_text,
        e.eligibility_years,
        e.eligibility_branches,
        e.team_size_text,
        e.apply_url,
        e.source_url,
        e.poster_r2_key,
        e.status,
        e.metadata,
        em.score AS match_score,
        em.matched_tags_arr AS matched_tags
    FROM public.events e
    JOIN event_matches em ON e.id = em.e_id
    ORDER BY em.score DESC, e.deadline_at ASC NULLS LAST, e.starts_at ASC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- ----------------------------------------------------------
-- 11. Seed Initial Sample Events
-- ----------------------------------------------------------
INSERT INTO public.clubs (name, description) VALUES
('Xavier AI & Coding Society', 'Official competitive programming and tech club at SXUK'),
('SXUK E-Cell', 'Entrepreneurship & Innovation Cell'),
('Robotics & IoT Club', 'Building hardware and IoT systems')
ON CONFLICT DO NOTHING;

DO $$
DECLARE
    v_club_id UUID;
    v_event1 UUID;
    v_event2 UUID;
    v_event3 UUID;
    v_event4 UUID;
BEGIN
    SELECT id INTO v_club_id FROM public.clubs LIMIT 1;

    INSERT INTO public.events (title, description, category, organizer_name, organizer_club_id, starts_at, ends_at, deadline_at, venue, format, eligibility_text, eligibility_years, eligibility_branches, team_size_text, apply_url)
    VALUES 
    (
        'XavCode Hackathon 2026',
        'Annual 36-hour flagship hackathon at SXUK. Build AI, Web3, and Mobile solutions with ₹1,00,000 in prizes.',
        'hackathon',
        'Xavier AI & Coding Society',
        v_club_id,
        now() + INTERVAL '10 days',
        now() + INTERVAL '12 days',
        now() + INTERVAL '5 days',
        'SXUK Innovation Lab & Auditorium',
        'hybrid',
        'All undergraduate and postgraduate students of SXUK and affiliated colleges',
        ARRAY[1,2,3,4],
        ARRAY['CSE', 'IT', 'ECE', 'Data Science'],
        '2-4 Members',
        'https://xavcode2026.devpost.com'
    ) RETURNING id INTO v_event1;

    INSERT INTO public.event_tags (event_id, tag) VALUES
    (v_event1, 'AI/ML'),
    (v_event1, 'Web Development'),
    (v_event1, 'Mobile App Dev'),
    (v_event1, 'Flutter'),
    (v_event1, 'Hackathons');

    INSERT INTO public.events (title, description, category, organizer_name, organizer_club_id, starts_at, ends_at, deadline_at, venue, format, eligibility_text, eligibility_years, eligibility_branches, team_size_text, apply_url)
    VALUES 
    (
        'Hands-on Flutter & Riverpod Workshop',
        'Deep dive into modern reactive Flutter state management, clean architecture, and responsive M3 design.',
        'workshop',
        'GDG On Campus SXUK',
        v_club_id,
        now() + INTERVAL '3 days',
        now() + INTERVAL '3 days 4 hours',
        now() + INTERVAL '2 days',
        'Seminar Hall 204',
        'in_person',
        'Open to all students interested in app development',
        ARRAY[1,2,3,4],
        ARRAY[]::TEXT[],
        'Individual',
        'https://gdg.community.dev/events'
    ) RETURNING id INTO v_event2;

    INSERT INTO public.event_tags (event_id, tag) VALUES
    (v_event2, 'Flutter'),
    (v_event2, 'Mobile App Dev'),
    (v_event2, 'Workshops');

    INSERT INTO public.events (title, description, category, organizer_name, organizer_club_id, starts_at, ends_at, deadline_at, venue, format, eligibility_text, eligibility_years, eligibility_branches, team_size_text, apply_url)
    VALUES 
    (
        'Summer FinTech Internship Drive 2026',
        'Exclusive summer analyst and software engineering internship opportunities for SXUK pre-final and final year students.',
        'internship',
        'SXUK Placement & Internship Cell',
        NULL,
        now() + INTERVAL '15 days',
        now() + INTERVAL '15 days',
        now() + INTERVAL '8 days',
        'Online Assessment + Campus Interviews',
        'hybrid',
        '3rd and 4th year B.Tech / BCA / MCA / B.Com students',
        ARRAY[3,4],
        ARRAY['CSE', 'IT', 'Finance', 'Economics'],
        'Individual',
        'https://forms.gle/sxuk-placement-fintech'
    ) RETURNING id INTO v_event3;

    INSERT INTO public.event_tags (event_id, tag) VALUES
    (v_event3, 'Internships'),
    (v_event3, 'Fintech'),
    (v_event3, 'Software Engineering');

    INSERT INTO public.events (title, description, category, organizer_name, organizer_club_id, starts_at, ends_at, deadline_at, venue, format, eligibility_text, eligibility_years, eligibility_branches, team_size_text, apply_url)
    VALUES 
    (
        'Xavotsav Cultural & Tech Fest 2026',
        'The biggest annual fest of St. Xavier University. Competitions in robotics, gaming, music, drama, and photography.',
        'fest',
        'SXUK Student Council',
        NULL,
        now() + INTERVAL '25 days',
        now() + INTERVAL '27 days',
        now() + INTERVAL '20 days',
        'Main Campus Grounds',
        'in_person',
        'Open to all SXUK students',
        ARRAY[1,2,3,4],
        ARRAY[]::TEXT[],
        'Solo & Team Events',
        'https://xavotsav.sxuk.edu.in'
    ) RETURNING id INTO v_event4;

    INSERT INTO public.event_tags (event_id, tag) VALUES
    (v_event4, 'Cultural'),
    (v_event4, 'Gaming'),
    (v_event4, 'Robotics'),
    (v_event4, 'Fest');
END $$;
