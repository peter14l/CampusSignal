# CampusSignal — Product Requirements Document
**For: Antigravity CLI (agentic build)**
**Platform: Flutter (Android-first, portrait)**
**Version:** 1.0 — Build PRD

---

## 1. Product Summary

CampusSignal is a personalized discovery layer for SXUK students. It
consolidates hackathons, competitions, workshops, internships, club
events, fests, and seminars — currently scattered across WhatsApp,
email, posters, and social media — into one adaptive, personalized
feed. Structured event data (name, date/time, deadline, eligibility,
venue, apply steps) is extracted from source material (posters, PDFs,
flyers) so students can go **Discover → Understand → Save/Remind →
Apply** in a tap.

This PRD assumes the UI/IA already validated in the Stitch screen set
(Splash, Auth, Onboarding ×2, Home Feed, Event Details, Search/Filter,
Saved, Calendar, Profile, Notifications) and defines how to build it as
a production Flutter app.

---

## 2. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter (latest stable channel) | Android-first; keep code platform-agnostic where trivial for future iOS |
| Design system | Material 3 Expressive | via the `material_3_expressive` package (`M3EMaterialApp`, `M3EThemeData`, M3E component set) layered on Flutter's native M3 `ColorScheme.fromSeed` |
| Navigation | `go_router` | declarative routing, deep-linkable, nested shell route for bottom-nav |
| State management | Riverpod (`flutter_riverpod` + `riverpod_generator`) | async providers per feature; keep UI stateless where possible |
| Backend | Supabase | Postgres + Auth (email OTP) + Row Level Security + Realtime + Edge Functions |
| Object storage | Cloudflare R2 | stores uploaded source documents/posters (originals) and derived event images; accessed via presigned URLs issued by a Supabase Edge Function (never expose R2 credentials client-side) |
| Local persistence | `drift` (SQLite) or `Isar` | offline cache of feed/saved/calendar for instant cold start |
| Push/local notifications | `firebase_messaging` (push) + `flutter_local_notifications` (reminders) | reminders are scheduled locally against event deadlines; push is for new-match/broadcast alerts |
| Animations | Flutter's implicit/explicit animation APIs + M3E's spring-based motion tokens (from `material_3_expressive`) | no ad-hoc easing curves outside the design system — see §5 |
| Networking | `supabase_flutter` client directly; `dio` only if a non-Supabase HTTP call is needed (e.g. presigned R2 upload PUT) | |

---

## 3. Architecture

- **Pattern:** Feature-first folder structure, MVVM-ish via Riverpod
  (`Notifier`/`AsyncNotifier` as the "ViewModel", widgets are pure
  presentation).
- **Folder skeleton:**
  ```
  lib/
    app/            # MaterialApp, theming, go_router config, DI setup
    core/           # shared widgets, extensions, constants, failures
    features/
      auth/
      onboarding/
      feed/
      event_details/
      search/
      saved/
      calendar/
      profile/
      notifications/
    data/
      supabase/      # typed table clients, repositories
      storage/       # R2 presigned-upload + fetch repository
      local/         # drift/Isar cache
    models/           # freezed data classes shared across features
  ```
- **Navigation shell:** `StatefulShellRoute` (go_router) with 4 branches
  — Home, Calendar, Saved, Profile — each preserving its own navigation
  stack. Event Details, Search, Notifications, and Onboarding/Auth push
  as top-level routes outside the shell.
- **Error/loading:** every async provider exposes `AsyncValue`; screens
  render a shared `M3ELoadingState` / `M3EErrorState` / empty-state
  widget set rather than ad hoc spinners.

---

## 4. Data Model

### 4.1 Supabase (Postgres) — core tables

```
profiles
  id            uuid PK, references auth.users
  full_name     text
  college_email text unique
  branch        text
  year          int
  interests     text[]         -- category tags
  skills        text[]
  metadata      jsonb default '{}'::jsonb  -- extensible JSON bucket for dynamic future profile fields
  created_at    timestamptz default now()
  updated_at    timestamptz default now()

events
  id                uuid PK default gen_random_uuid()
  title             text
  description       text
  category          text            -- hackathon | internship | workshop | fest | seminar | club | networking | sports
  organizer_name    text
  organizer_club_id uuid FK -> clubs.id nullable
  starts_at         timestamptz
  ends_at           timestamptz
  deadline_at       timestamptz nullable
  venue             text
  format            text            -- online | in_person | hybrid
  eligibility_text  text
  eligibility_years int[] nullable
  eligibility_branches text[] nullable
  team_size_text    text nullable
  apply_url         text
  source_url        text nullable
  poster_r2_key     text nullable   -- key into R2 bucket, not a public URL
  status            text            -- draft | published | archived
  metadata          jsonb default '{}'::jsonb  -- extensible JSON bucket for dynamic future attributes (fees, prizes, etc.)
  created_by        uuid FK -> profiles.id
  created_at        timestamptz default now()
  updated_at        timestamptz default now()

event_tags               -- normalized skill/interest match tags per event
  event_id  uuid FK
  tag       text

saves
  user_id    uuid FK
  event_id   uuid FK
  saved_at   timestamptz default now()
  PK (user_id, event_id)

reminders
  id          uuid PK default gen_random_uuid()
  user_id     uuid FK
  event_id    uuid FK
  remind_at   timestamptz
  fired       boolean default false

applications                -- optional lightweight self-reported tracking
  user_id    uuid FK
  event_id   uuid FK
  applied_at timestamptz default now()
  PK (user_id, event_id)

notifications
  id          uuid PK default gen_random_uuid()
  user_id     uuid FK
  type        text        -- reminder | deadline_soon | new_match | system
  title       text
  body        text
  event_id    uuid FK nullable
  read        boolean default false
  created_at  timestamptz default now()

clubs
  id          uuid PK default gen_random_uuid()
  name        text
  logo_r2_key text nullable
  metadata    jsonb default '{}'::jsonb
```

- **RLS:** `profiles`/`saves`/`reminders`/`applications`/`notifications`
  are row-owned (`user_id = auth.uid()`). `events`/`clubs` are publicly
  readable when `status = 'published'`; writes restricted to a
  `club_admin`/`service_role` claim.
- **Personalization/ranking** is computed client-side or in an Edge
  Function (`rank_events`) that scores published events against a
  profile's `interests`/`skills`/`branch`/`year` and returns an ordered
  feed — do not hardcode ranking logic into the Flutter client so it can
  evolve without an app release.

### 4.2 Schema Evolution & Defensive Architecture Guidelines

To ensure the database schema can evolve, expand, and modify over time without breaking deployed Flutter clients:
1. **Additive Changes First**: When adding columns or relations in Postgres, always specify `DEFAULT NULL` or provide a default value (e.g. `DEFAULT '{}'::text[]`). Never drop or rename existing columns in production without multi-version deprecation.
2. **`metadata` JSONB Extension Buckets**: Core tables (`events`, `profiles`, `clubs`) include a `metadata` JSONB column (`DEFAULT '{}'::jsonb`). Unplanned or experimental attributes (e.g. `prize_pool`, `entry_fee`, `discord_link`) can be stored and queried immediately without running database migrations.
3. **Defensive Client Deserialization (Freezed + json_serializable)**:
   - All optional/future fields in Dart models must be nullable or provide `@Default(...)` values.
   - Enums must use `@JsonKey(unknownEnumValue: ...)` so new categories or status types introduced in the database do not crash older client versions.
   - Client queries must request explicit column lists or rely on version-stable DB Views / RPCs instead of raw unconstrained `SELECT *`.
4. **Local Migration Branching**: Schema changes are authored and tested as versioned SQL migration files (`supabase/migrations/`) verified against local Supabase CLI instances before deploying to production.

### 4.3 Cloudflare R2

- One bucket for **source documents** (raw uploaded posters/PDFs, for
  the OCR/ingestion pipeline) and one bucket (or prefixed path) for
  **derived event images** shown in the app.
- Flutter never talks to R2 directly with long-lived credentials. A
  Supabase Edge Function issues short-lived **presigned URLs**:
  - `POST /r2/upload-url` → presigned PUT URL + the `r2_key` to save on
    the `events` row (admin/ingestion flow, likely used by a separate
    admin tool, not the student-facing app).
  - `GET /r2/read-url?key=...` → presigned GET URL, cached client-side
    with the object's own cache headers so repeat feed scrolls don't
    re-request signing.
- Store only the `r2_key` in Postgres, never a permanent public URL.

---

## 5. Design System & Motion Requirements

- Implement theming via `M3EMaterialApp` + `M3EThemeData.light()` /
  `.dark()` seeded from the CampusSignal indigo-violet seed color
  (`0xFF4F55D6`), with `dynamicColoring: true` and
  `drawUnderSystemBars: true` for true edge-to-edge (system status/nav
  bars transparent, content draws behind them, `SafeArea`/`viewPadding`
  used deliberately per-screen rather than globally).
- Use M3E component widgets (`M3ENavigationBar`, M3E buttons/chips/
  cards/FAB) rather than hand-rolling look-alikes, so motion and shape
  tokens stay consistent with the earlier style guide (tonal color
  roles, 6-step shape scale, 15-style type scale, spring-based motion).
- **Predictive back gesture:** rely on Flutter's built-in
  `PredictiveBackPageTransitionsBuilder` (default for `MaterialApp` on
  Android since Flutter 3.38) — do not override page transitions with a
  custom `PageTransitionsTheme` that would disable it. Requires:
  - `android:targetSdkVersion 34+` (Android 14/"U") in
    `android/app/build.gradle`.
  - `android:enableOnBackInvokedCallback="true"` on the `<application>`
    tag in `AndroidManifest.xml`.
  - Every dismissible surface (bottom sheets, full-screen modals like
    Search) uses `PopScope`/`NavigatorPopHandler` correctly so the
    predictive-back preview reflects the right destination, not a
    black frame.
- **Edge-to-edge:** enabled app-wide; `Scaffold`s must account for
  `MediaQuery.viewPadding` for the bottom nav bar and gesture area
  (M3E's `M3ENavigationBar` already insets correctly per its docs) and
  for the status bar behind translucent top app bars/headers (e.g. the
  Event Details banner image).
- **Motion/"smoothness" bar:** target 60/120fps on mid-range devices —
  no jank on feed scroll (use `ListView.builder`/slivers, not building
  full lists eagerly), shared-element-style hero transition from a feed
  card into Event Details, spring-based (not linear/ease-in-out) curves
  for chip selection, FAB morph, and bottom-sheet entry, consistent
  with M3E's physics-based motion tokens. Test with
  `flutter run --profile` + DevTools performance overlay before closing
  out each phase.

---

## 6. Build Phases

Each phase should be a separate PR-sized unit of work with its own
acceptance criteria. Phases 0–2 are foundational and blocking; 3–8 can
partly parallelize once the shell exists.

### Phase 0 — Project Scaffold & Infrastructure
- Init Flutter project, package name/app id, min/target SDK (target 34+
  for predictive back).
- Add core deps: `material_3_expressive`, `go_router`,
  `flutter_riverpod` + `riverpod_generator`, `supabase_flutter`,
  `freezed`/`json_serializable`, `drift` or `Isar`,
  `flutter_local_notifications`, `firebase_messaging`.
- Wire Supabase project (URL + anon key via `--dart-define`/env, never
  committed) and confirm a basic `supabase.auth` round trip.
- Enable edge-to-edge + `enableOnBackInvokedCallback` in the Android
  manifest/gradle files (see §5) even before UI exists, so every later
  screen inherits it.
- Set up lint rules, CI (format + analyze + test on push), and a
  `flavors`/env split (dev vs prod Supabase project).
- **Acceptance:** app boots to a blank M3E-themed scaffold on a real
  Android 14+ device with transparent system bars and working
  predictive-back on a trivial two-route test.

### Phase 1 — Design System Foundation
- Implement `M3EThemeData` (light + dark) from the seed color; wire
  `dynamicColoring`.
- Build the shared widget library: `M3EEventCard`, `M3EFilterChipRow`,
  `M3ELoadingState`, `M3EEmptyState`, `M3EErrorState`, urgency/category
  chip helpers (color role → category mapping).
- Establish the shared spring/motion constants (durations/curves) as a
  single `motion.dart` source of truth.
- **Acceptance:** a component gallery/debug route renders every shared
  widget in both themes; no screen-specific code duplicates
  chip/card styling.

### Phase 2 — Auth & Onboarding
- Supabase email-OTP auth restricted to the college email domain
  (validate domain client-side + Postgres check constraint).
- `profiles` table row created on first sign-in (Edge Function or
  Postgres trigger).
- Onboarding flow (Profile Basics → Interests) writes `branch`, `year`,
  `interests`, `skills` to `profiles`.
- Session persistence (auto-login on relaunch) via `supabase_flutter`'s
  local session storage.
- **Acceptance:** fresh install → sign in with college email → OTP →
  complete 2-step onboarding → lands on Home Feed; relaunching the app
  skips straight to Home Feed while signed in.

### Phase 3 — Home Feed & Ranking
- `events` repository (Supabase query + local cache) and the
  `rank_events` Edge Function integration for personalized ordering.
- Home Feed screen: greeting header, filter chip row, infinite-scroll
  event card list (paginated), pull-to-refresh.
- Card → Event Details hero-style transition.
- Offline: last-fetched feed page renders instantly from local cache
  while a fresh page loads in the background.
- **Acceptance:** feed reflects onboarding interests in ordering; cold
  start with cache shows content in <300ms before network resolves;
  scroll stays smooth per §5's performance bar.

### Phase 4 — Event Details & Actions
- Full details screen bound to a single `events` row + derived R2 image
  via presigned URL.
- Save (toggle `saves` row), Remind (writes `reminders` row + schedules
  a local notification), Apply (opens `apply_url` externally, records
  `applications` row), Share (native share sheet with `source_url`).
- "Why this is for you" chip callout computed from matched
  `interests`/`skills` vs `event_tags`.
- **Acceptance:** all four actions work against real Supabase data and
  survive app restart (reminder still fires, save state persists).

### Phase 5 — Search & Filters
- Full-text/trigram search over `events.title`/`description` (Postgres
  `pg_trgm` or Supabase full-text search) exposed via an RPC.
- Filter sheet (category/deadline/eligibility/format) composes into the
  same query the feed uses, so results are consistent with feed
  ranking rules.
- Recent searches stored locally (not in Supabase — device-local only).
- **Acceptance:** search + filter combination returns correct results
  within ~1s on a representative seeded dataset (500+ events).

### Phase 6 — Saved & Calendar
- Saved screen: list bound to `saves`, grouped by date proximity,
  Saved/Reminders segmented toggle.
- Calendar/Agenda screen: events grouped by date from `saves` +
  `reminders` (or all upcoming relevant events — confirm scope with
  product before building); **conflict detection** flags overlapping
  `starts_at`/`ends_at` windows on the same day and renders the
  "Time conflict" chip treatment from the Stitch spec.
- **Acceptance:** two saved events with overlapping times visibly flag
  as conflicting; removing one clears the flag live.

### Phase 7 — Profile & Settings
- Editable profile screen (branch/year/interests/skills) writing back
  to `profiles`.
- Stats chips (saved/applied/reminders counts) via simple count
  queries.
- Settings list: notification preferences (push/local toggles),
  linked-channels placeholder, privacy/data, help, log out (clears
  session + local cache).
- **Acceptance:** editing interests immediately changes subsequent Home
  Feed ranking on next fetch.

### Phase 8 — Notifications
- Local notifications fire at each `reminders.remind_at`.
- Push notifications (Firebase Cloud Messaging via Supabase Edge
  Function trigger) for `new_match` and `deadline_soon` system-
  generated alerts; tapping deep-links into Event Details via
  `go_router`.
- In-app Notifications screen bound to the `notifications` table,
  grouped Today/Earlier, unread-state dot, mark-all-read.
- **Acceptance:** a reminder set 1 minute out fires a local
  notification that deep-links correctly even from a cold start.

### Phase 9 — Polish, Performance, Release Readiness
- Full pass on animation smoothness (§5) across all screens with
  DevTools profiling; fix any jank on list scroll, transitions, and
  the FAB morph.
- Accessibility pass: minimum touch targets, contrast on custom tonal
  chips, screen-reader labels, dynamic text scaling support.
- Empty/error states verified for every list-based screen (Feed,
  Saved, Calendar, Search, Notifications).
- App icon, splash (native splash matching the Stitch splash screen),
  versioning, release signing config, basic crash reporting
  (`firebase_crashlytics` or Sentry).
- **Acceptance:** release-profile build passes a manual QA pass against
  every acceptance criterion above on a physical Android 14+ device.

---

## 7. Non-Functional Requirements

- **Performance:** cold start < 2s to interactive Home Feed on a
  mid-range device with cache; feed scroll and predictive-back preview
  must not drop below ~55fps in profile mode.
- **Security:** all Supabase access via RLS-scoped anon key; no R2
  credentials in client code or `.env` shipped to the app bundle;
  college-email domain enforced both client- and DB-side.
- **Offline resilience:** Home Feed, Saved, and Calendar must render
  last-known data with no network, clearly indicating stale/offline
  state.
- **Testability:** repositories behind interfaces so Supabase/R2 can be
  mocked in widget/unit tests; at minimum, unit tests for ranking-query
  composition and conflict-detection logic, widget tests for the shared
  M3E component library.

---

## 8. Explicitly Out of Scope (this PRD)

- The OCR/AI-NLP ingestion pipeline that turns raw posters/PDFs into
  structured `events` rows — assumed to be a separate
  admin/ingestion service that only needs the R2 upload contract in
  §4.2 to exist.
- iOS-specific polish (predictive back and edge-to-edge behavior above
  are Android concepts; iOS should not regress but is not a target
  platform for this build).
- Club/organizer-facing admin app.

---

## 9. Open Questions for Product Before Phase 6

1. Does the Calendar screen show *all* relevant upcoming events, or
   only Saved/Reminded ones? (affects the query in Phase 6)
2. Is "Applied" self-reported only, or should Apply eventually deep-
   link into a tracked application flow with a partner ATS/form?
