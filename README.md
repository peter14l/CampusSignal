# CampusSignal 📡

[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Stable-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Design System](https://img.shields.io/badge/Design-Material%203%20Expressive-6750A4?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Storage](https://img.shields.io/badge/Storage-Cloudflare%20R2-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)](https://developers.cloudflare.com/r2)
[![AI Engine](https://img.shields.io/badge/AI%20OCR-Gemini%20Vision-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/peter14l/CampusSignal/actions)

> **CampusSignal** is a personalized, high-performance campus discovery layer for university students (St. Xavier's University, Kolkata / SXUK). It consolidates hackathons, competitions, workshops, internships, club activities, seminars, and fests into an adaptive, zero-latency feed with native calendar sync, AI flyer extraction, and department-targeted broadcasts.

---

## 📱 App Highlights & Architecture Overview

```
                                  ┌───────────────────────────┐
                                  │   Multimodal Gemini OCR   │
                                  │ (Vision Flyer Extraction) │
                                  └─────────────┬─────────────┘
                                                │ (Structured JSON)
┌───────────────────────────┐     ┌─────────────▼─────────────┐     ┌───────────────────────────┐
│     Cloudflare R2 CDN     │◄────┤  CampusSignal Studio App  ├────►│     Supabase Postgres     │
│ (Zero-Egress Object Host) │     │(Flutter + M3 Expressive)  │     │(Auth, RLS, Realtime Sync) │
└───────────────────────────┘     └─────────────┬─────────────┘     └───────────────────────────┘
                                                │
                                  ┌─────────────▼─────────────┐
                                  │    FCM & Native Alarms    │
                                  │(Targeted Push Broadcasts) │
                                  └───────────────────────────┘
```

### ✨ Core Features

1. **🎨 Authentic Material 3 Expressive (M3E) Design System**:
   - **Active Geometry Morphing**: Action buttons dynamically morph geometry between resting circles, compressed states, and expressive squircles (`M3EMorphIconButton`).
   - **Spring Motion Tokens**: Physics-based acceleration and deceleration curves (`AppMotion.emphasizedDecelerate`, `AppMotion.spring`) tuned for 60/120 FPS high-refresh-rate displays.
   - **Tactile Haptics**: Light tactile feedback integrated across all interactive components without visual clutter.

2. **🤖 AI Poster-to-Announcement Studio**:
   - Upload any event poster or flyer directly from device gallery.
   - **Multimodal Gemini Vision OCR** parses unstructured typography and extracts title, organizing body, category, dates, application deadlines, eligibility criteria, venue/mode, URLs, and branch tags.
   - Interactive review step allows editors to verify and tweak details before broadcasting.

3. **🏢 Department & Branch Visibility Engine**:
   - Supports both campus-wide broadcasts and department-targeted announcements (e.g. *Computer Science & Engineering*, *Data Science & AI*, *Information Technology*, *BBA / MBA*, *Commerce*, *Law*, *Mass Communication*).
   - Students receive feeds tailored to their registered academic profile while retaining the ability to filter cross-department opportunities.

4. **⚡ High-Speed Cloudflare R2 Storage & In-Memory Byte Caching**:
   - Production-grade poster hosting on Cloudflare R2 (`campussignal-media`) with instant global edge delivery.
   - Local in-memory byte caching prevents redundant network calls during flyer inspection.

5. **📅 Academic Deadline & Calendar Engine**:
   - One-tap native system calendar synchronization (`add_2_calendar`) with pre-filled event alarms and registration reminders.
   - Local and push notification reminders prior to application deadlines.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose / Highlights |
|---|---|---|
| **Frontend Framework** | **Flutter 3.x (Dart 3)** | Android-first, cross-platform ready with Clean Architecture |
| **State Management** | **Riverpod (v2/v3)** | Reactive, type-safe dependency injection & `AsyncNotifier` controllers |
| **Design Language** | **Material 3 Expressive (M3E)** | Custom shape morphing, squircle transitions, dynamic color palettes |
| **Navigation** | **GoRouter** | Declarative deep-linking with `StatefulShellRoute` indexed stack |
| **Backend & Auth** | **Supabase (Postgres + RLS)** | Row-Level Security, Realtime streams, and OTP/Password authentication |
| **Object Storage** | **Cloudflare R2** | S3-compatible, zero-egress asset storage with global CDN |
| **Multimodal AI** | **Google Gemini 2.5 / 1.5 Flash** | High-speed flyer OCR and structured JSON opportunity synthesis |
| **Push Notifications** | **FCM & Local Notifications** | Native high-priority system alerts and targeted branch broadcasts |
| **CI / CD Pipeline** | **GitHub Actions** | Automated keystore injection, split-per-ABI builds, and GitHub releases |

---

## 📂 Project Structure

```
CampusSignal/
├── .github/
│   └── workflows/
│       └── release.yml                # Automated Split-ABI build & GitHub release pipeline
├── android/                           # Native Android Gradle configuration (Java 17, Proguard)
│   ├── app/
│   │   ├── build.gradle.kts           # Keystore resolution & desugaring config
│   │   └── campussignal-release.jks   # Android release signing keystore
│   └── key.properties.example         # Signing property template
├── ios/                               # iOS native project structure
├── lib/
│   ├── app/
│   │   ├── app.dart                   # Root MaterialApp with M3E ThemeData
│   │   ├── router.dart                # GoRouter routing with StatefulShellRoute
│   │   └── scaffold_with_nav_bar.dart # Edge-to-edge M3 navigation scaffold
│   ├── core/
│   │   ├── config/                    # Environment & Supabase credentials
│   │   ├── constants/                 # Category keys, labels, academic departments
│   │   ├── services/
│   │   │   ├── calendar_sync_service.dart     # System calendar integration
│   │   │   ├── fcm_notification_service.dart  # Native system push notifications
│   │   │   ├── gemini_ocr_service.dart        # Multimodal Gemini Vision OCR engine
│   │   │   └── r2_storage_service.dart        # Cloudflare R2 upload & memory cache
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # Expressive color palettes & tonal containers
│   │   │   ├── app_theme.dart         # Material 3 light/dark theme configurations
│   │   │   └── motion.dart            # M3E spring & cubic physics tokens
│   │   └── widgets/
│   │       ├── app_logo_badge.dart    # Brand squircle logo component
│   │       ├── category_chip.dart     # Tinted category badge with spring response
│   │       ├── interactive_spring.dart# Elastic spring touch feedback wrapper
│   │       ├── m3e_event_card.dart    # Expressive event card with hero transitions
│   │       ├── m3e_filter_chip_row.dart# Horizontal filter row for categories & branches
│   │       ├── m3e_header.dart        # Expressive AppBar header with brand badge
│   │       ├── m3e_morph_button.dart  # Authentic M3E geometry shape-morphing buttons
│   │       └── m3e_speed_dial_fab.dart# Expandable animated FAB for opportunity creation
│   ├── data/
│   │   ├── repositories/
│   │   │   └── events_repository.dart # Zero-latency caching & Supabase repository
│   │   └── supabase/                  # Typed table clients, user actions, profile repositories
│   ├── features/
│   │   ├── announcements/             # AI Announcement Studio (OCR, review, publish)
│   │   ├── auth/                      # Authentication screen & controller
│   │   ├── calendar/                  # Calendar deadline view & synchronizer
│   │   ├── event_details/             # Collapsing hero view, RSVP, calendar sync
│   │   ├── feed/                      # Main campus feed with department filter chips
│   │   ├── notifications/             # In-app notifications center
│   │   ├── onboarding/                # Academic branch & interest personalization wizard
│   │   ├── profile/                   # Academic profile & tags editor
│   │   ├── saved/                     # Bookmarks & saved opportunities
│   │   ├── search/                    # Instant multi-tag & keyword search modal
│   │   ├── settings/                  # User preferences & theme switch
│   │   └── splash/                    # Revamped branded splash screen
│   └── models/
│       ├── club_model.dart            # Campus societies & clubs
│       ├── event_model.dart           # Event entity with branch targeting logic
│       ├── notification_model.dart    # Notification payload entity
│       └── profile_model.dart         # Academic student profile
├── pubspec.yaml                       # Dependencies & asset manifests
└── README.md                          # Project documentation
```

---

## 🗄️ Backend & Cloud Storage Architecture

### 1. Database Schema (Supabase Postgres)

The backend runs on PostgreSQL with Row-Level Security (RLS):

- **`profiles`**: Student academic profiles (`id`, `full_name`, `college_email`, `branch`, `year`, `interests`, `skills`, `metadata`).
- **`events`**: Campus announcements (`title`, `description`, `category`, `organizer_name`, `start_time`, `deadline_at`, `venue`, `format`, `eligibility_branches`, `apply_url`, `poster_r2_key`, `tags`).
- **`saved_events`**: Student bookmarks with unique constraints (`user_id`, `event_id`).
- **`event_reminders`**: Scheduled alarms against application deadlines.

### 2. Cloudflare R2 Object Storage

Media is organized inside the `campussignal-media` bucket:

```
campussignal-media/
├── posters/          # High-resolution event flyers
├── thumbnails/       # Lightweight WebP assets for fast scrolling
├── avatars/          # Profile avatars (students & clubs)
├── attachments/      # Event rulebooks, brochures, and circulars
└── temp/             # Ephemeral OCR scanning uploads
```

---

## 🚀 CI/CD & Automated Release Pipeline

The repository includes a GitHub Actions workflow ([`.github/workflows/release.yml`](.github/workflows/release.yml)) configured to automate release packaging:

- **Dynamic Flutter SDK**: Always pulls the latest stable Flutter channel.
- **Secure Keystore Injection**: Decodes the encrypted Android release keystore from repository secrets without storing raw credentials in git.
- **Split-per-ABI Builds**:
  - `CampusSignal-v1.0.0-arm64-v8a.apk` *(Modern 64-bit phones)*
  - `CampusSignal-v1.0.0-armeabi-v7a.apk` *(Legacy 32-bit devices)*
  - `CampusSignal-v1.0.0-x86_64.apk` *(Emulators & Chromebooks)*
  - `CampusSignal-v1.0.0-universal.apk` *(All-in-one universal package)*
  - `checksums.sha256` *(Automated integrity verification)*
- **Automatic GitHub Releases**: Created automatically on pushing version tags (`v*`) or via manual dispatch from GitHub Actions.

---

## 💻 Local Setup & Development

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- [Android Studio](https://developer.android.com/studio) / VS Code with Flutter extensions
- Java JDK 17
- [GitHub CLI (`gh`)](https://cli.github.com) *(optional, for secret and workflow management)*

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/peter14l/CampusSignal.git
   cd CampusSignal
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Code Quality**:
   ```bash
   flutter analyze
   ```

4. **Run on Connected Device / Emulator**:
   ```bash
   flutter run
   ```

5. **Build Release APKs**:
   ```bash
   # Build Split-per-ABI APKs
   flutter build apk --release --split-per-abi

   # Build Universal Release APK
   flutter build apk --release
   ```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
