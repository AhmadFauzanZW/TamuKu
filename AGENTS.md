# AGENTS.md — TamuKu: Buku Tamu Digital

> AI Agent Governance File for the TamuKu Project
> All AI assistants, copilots, and coding agents MUST read this file before making any changes.

---

## 1. Project Overview

**TamuKu** is a digital guest book mobile application built with Flutter and Firebase. It replaces traditional paper-based guest registration at government offices, company reception desks, and public service locations with a modern QR-code-based check-in/check-out system.

**Goals:**
- Digitalize guest registration for any physical location
- Provide admins real-time guest tracking via a mobile dashboard
- Send automatic WhatsApp/FCM notifications when guests arrive
- Export guest data for reporting and compliance

**Success Criteria:**
- Guest can scan QR → fill form → check-in within 30 seconds
- Admin sees guest arrival in real-time on dashboard
- Notification delivered to host within 10 seconds of check-in
- 80%+ test coverage on services layer
- Zero `flutter analyze` issues

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                    TamuKu App                     │
│                                                   │
│  ┌──────────────┐       ┌──────────────────────┐ │
│  │  Guest Flow   │       │    Admin Flow         │ │
│  │  (Web View)   │       │    (Mobile App)       │ │
│  │               │       │                       │ │
│  │  Scan QR      │       │  Login (Email/Google) │ │
│  │  Fill Form    │       │  Dashboard            │ │
│  │  Check-in/out │       │  Guest List           │ │
│  └──────┬───────┘       │  QR Generator         │ │
│         │               │  Settings              │ │
│         │               └──────────┬────────────┘ │
│         │                          │               │
│         └──────────┬───────────────┘               │
│                    │                               │
│            ┌───────▼────────┐                      │
│            │  BLoC Layer    │                      │
│            │  (Events →     │                      │
│            │   States)      │                      │
│            └───────┬────────┘                      │
│                    │                               │
│            ┌───────▼────────┐                      │
│            │  Repository    │                      │
│            │  Layer         │                      │
│            └───────┬────────┘                      │
│                    │                               │
│         ┌──────────┴──────────┐                    │
│         │                     │                    │
│   ┌─────▼─────┐      ┌──────▼──────┐             │
│   │  Remote   │      │   Local     │             │
│   │  (Firebase)│      │  (SQLite/   │             │
│   │           │      │  Hive)      │             │
│   └───────────┘      └─────────────┘             │
└───────────────────────────────────────────────────┘
```

**Two user flows:**
1. **Guest (Unauthenticated)** — QR scan → form → check-in/out. No login required.
2. **Admin (Authenticated)** — Email/Google sign-in → full dashboard with CRUD operations.

**Notification pipeline:**
- Guest checks in → Firestore write → Contabo backend API reads event → backend sends FCM push notification + WhatsApp API message to host phone.

---

## 2.1 Course-Mandated Concepts (Mobile Computing UAS)

This project MUST demonstrate the following concepts from the Mobile Computing course. Each concept is mapped to its implementation:

| # | Concept | Session | Implementation in TamuKu |
|---|---------|---------|------------------------|
| A | **Flutter Widgets** (Basics, Layout, Scrolling, Text) | 1 & 2 | All screens use proper widget composition: `Scaffold`, `Column`, `Row`, `Stack`, `Expanded`, `Flexible`, `ListView.builder`, `GridView`, `SingleChildScrollView`, `TextEditingController`, `TextStyle`, `TextFormField` |
| B | **ListView.builder** | 2 | Guest list screen, dashboard recent guests — lazy-loaded, efficient scrolling for large lists |
| C | **FutureBuilder & StreamBuilder** | 3 | `StreamBuilder` for real-time Firestore guest updates; `FutureBuilder` for one-time loads (QR generation, settings) |
| D | **BLoC (Business Logic Component)** | 4–5 | All state management via BLoC/Cubit pattern. Separation of UI ↔ Business Logic ↔ Data |
| E | **API Integration with BLoC** | 5 | Firebase Firestore as API layer, consumed via Repository → BLoC → UI. REST API calls wrapped in Repository pattern |
| F | **Local Storage (Offline Fallback)** | 6 | SQLite/Hive for offline guest data, form drafts, settings cache. Sync queue for pending writes |
| G | **Popular Libraries** | 7 | qr_flutter, mobile_scanner, fl_chart, image_picker, hive, equatable, google_fonts, cached_network_image, intl, share_plus |

### Widget Showcase (Concept A)

Every screen must demonstrate proper Flutter widget usage:

| Widget Category | Widgets Used | Where |
|----------------|-------------|-------|
| **Layout** | `Scaffold`, `SafeArea`, `Padding`, `Center`, `Expanded`, `Flexible`, `ConstrainedBox`, `AspectRatio` | All screens |
| **Scrolling** | `ListView.builder`, `GridView.count`, `SingleChildScrollView`, `CustomScrollView`, `SliverList` | Guest list, dashboard, settings |
| **Text** | `Text`, `TextFormField`, `RichText`, `AutoSizeText`, `TextStyle`, `TextTheme` | Forms, labels, stats |
| **Input** | `TextField`, `TextFormField`, `DropdownButtonFormField`, `Checkbox`, `Switch`, `IconButton` | Guest form, settings, search |
| **Display** | `Card`, `ListTile`, `CircleAvatar`, `Chip`, `Badge`, `Divider`, `CircularProgressIndicator` | All list views, dashboard |
| **Navigation** | `AppBar`, `Drawer`, `BottomNavigationBar`, `Navigator.push`, `Navigator.pop`, `showModalBottomSheet` | Admin flow |
| **Feedback** | `SnackBar`, `AlertDialog`, `BottomSheet`, `Toast`, shimmer loading | Error handling, confirmations |

### BLoC Architecture Pattern (Concept D & E)

```
UI (Screen/BlocProvider)
    │
    ├── listens to ──→ Stream<BlocState>
    │
    └── dispatches ──→ Event → Bloc (EventHandler)
                           │
                           ├── calls ──→ Repository Method
                           │                 │
                           │                 ├──→ FirebaseRemoteDataSource (online)
                           │                 │
                           │                 └──→ LocalDataSource (offline fallback)
                           │
                           └── emits ──→ New State
```

### Offline-First Strategy (Concept F)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   UI Layer  │◄────│  BLoC Layer │◄────│ Repository  │
│  (Widgets)  │     │  (States)   │     │   Layer     │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                                    ┌───────────┴───────────┐
                                    │                       │
                             ┌──────▼──────┐       ┌───────▼──────┐
                             │   Remote    │       │    Local     │
                             │ DataSource  │       │  DataSource  │
                             │  (Firebase) │       │ (SQLite/Hive)│
                             └─────────────┘       └──────────────┘

Write path:  User Action → BLoC → Repository → Local (immediate) → Remote (when online)
Read path:   Repository → Remote (if online) → Local fallback → BLoC → UI
Sync path:   Background queue processes pending writes when connectivity restored
```

### Popular Libraries Reference (Concept G)

| Library | Purpose | When Used |
|---------|---------|-----------|
| `flutter_bloc` | BLoC/Cubit state management | All screens |
| `equatable` | Value equality for states/events | All BLoC states & events |
| `cloud_firestore` | Real-time database | All data operations |
| `firebase_auth` | Authentication | Admin login |
| `firebase_core` | Firebase initialization | App startup |
| `firebase_messaging` | Push notifications | Guest check-in alerts |
| `http` | HTTP client | Contabo backend API calls |
| `qr_flutter` | QR code generation | QR generator screen |
| `mobile_scanner` | QR code scanning | Guest scan screen |
| `fl_chart` | Charts and graphs | Dashboard 7-day chart |
| `image_picker` | Camera/gallery access | Guest photo capture |
| `hive` / `hive_flutter` | Local NoSQL storage | Offline data cache |
| `sqflite` | Local SQL database | Structured offline data |
| `google_fonts` | Custom typography | App typography |
| `cached_network_image` | Image caching | Guest photos, logos |
| `intl` | Date/number formatting | Indonesian locale formatting |
| `share_plus` | Share functionality | QR code sharing |
| `connectivity_plus` | Network status detection | Offline/online switching |
| `path_provider` | File system paths | Local storage paths |

---

## 3. Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Dart | 3.x |
| Framework | Flutter | 3.x (latest stable) |
| **State Management** | **flutter_bloc** | **8.x** |
| **State Equivalence** | **equatable** | **2.x** |
| **Backend API** | **ElysiaJS + Bun** | **5.x** |
| **Backend Host** | **Contabo VPS** | — |
| Database | Cloud Firestore | — |
| Authentication | Firebase Auth (Email + Google OAuth) | — |
| **Local Storage (Offline)** | **hive** + **sqflite** | — |
| QR Generation | qr_flutter | 4.x |
| QR Scanning | mobile_scanner | 5.x |
| Image Picker | image_picker | — |
| **File Storage** | **Contabo S3 (minio)** | — |
| Notifications | FCM + WhatsApp Business API | — |
| **Charts** | **fl_chart** | — |
| **Network Detection** | **connectivity_plus** | — |
| **Image Caching** | **cached_network_image** | — |
| **Date Formatting** | **intl** | — |
| Linting | flutter_lints + analysis_options.yaml | strict |
| Code Gen | freezed + json_serializable | — |

---

## 4. Folder Structure

```
tamuku/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart          # All hardcoded values
│   │   ├── theme/
│   │   │   ├── app_colors.dart             # Color tokens from DESIGN.md
│   │   │   ├── app_text_styles.dart        # Typography from DESIGN.md
│   │   │   └── app_theme.dart              # ThemeData light + dark
│   │   ├── routes/
│   │   │   └── app_router.dart             # Named routes + GoRouter
│   │   ├── utils/
│   │   │   ├── validators.dart             # Form validation
│   │   │   ├── formatters.dart             # Date/number formatting
│   │   │   └── permissions.dart            # Camera/storage permissions
│   │   └── errors/
│   │       ├── failures.dart               # Custom failure classes
│   │       └── exceptions.dart             # Custom exception classes
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       └── screens/
│   │   │           └── login_screen.dart
│   │   │
│   │   ├── guest/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── guest_remote_datasource.dart
│   │   │   │   │   └── guest_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── guest_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── guest_entity.dart
│   │   │   │   └── repositories/
│   │   │   │       └── guest_repository.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── guest_bloc.dart
│   │   │       │   ├── guest_event.dart
│   │   │       │   └── guest_state.dart
│   │   │       └── screens/
│   │   │           ├── scan_screen.dart
│   │   │           ├── guest_form_screen.dart
│   │   │           ├── confirmation_screen.dart
│   │   │           ├── checkout_screen.dart
│   │   │           └── error_screen.dart
│   │   │
│   │   ├── location/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── location_remote_datasource.dart
│   │   │   │   │   └── location_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── location_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── location_entity.dart
│   │   │   │   └── repositories/
│   │   │   │       └── location_repository.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── location_bloc.dart
│   │   │       │   ├── location_event.dart
│   │   │       │   └── location_state.dart
│   │   │       └── screens/
│   │   │           ├── dashboard_screen.dart
│   │   │           ├── guest_list_screen.dart
│   │   │           ├── qr_generator_screen.dart
│   │   │           └── settings_screen.dart
│   │   │
│   │   └── notification/
│   │       ├── data/
│   │       │   └── repositories/
│   │       │       └── notification_repository_impl.dart
│   │       ├── domain/
│   │       │   └── repositories/
│   │       │       └── notification_repository.dart
│   │       └── presentation/
│   │           └── bloc/
│   │               ├── notification_bloc.dart
│   │               ├── notification_event.dart
│   │               └── notification_state.dart
│   │
│   ├── shared/
│   │   └── widgets/
│   │       ├── app_bar_widget.dart
│   │       ├── stat_card.dart
│   │       ├── guest_tile.dart
│   │       ├── search_bar.dart
│   │       ├── filter_chips.dart
│   │       ├── loading_indicator.dart
│   │       ├── error_widget.dart
│   │       └── empty_state.dart
│   │
│   └── injection_container.dart             # Dependency injection setup
│
├── assets/
│   ├── images/
│   │   └── logo.png
│   └── fonts/
│
├── test/
│   ├── unit/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── guest/
│   │   │   └── location/
│   │   └── core/
│   ├── widget/
│   │   └── features/
│   │       ├── auth/
│   │       ├── guest/
│   │       └── location/
│   ├── bloc/
│   │   ├── auth_bloc_test.dart
│   │   ├── guest_bloc_test.dart
│   │   └── location_bloc_test.dart
│   └── integration/
│       └── guest_flow_test.dart
│
├── android/
├── ios/
├── backend/                                     # Contabo VPS backend
│   ├── package.json
│   ├── tsconfig.json
│   ├── .env.example
│   ├── Dockerfile
│   └── src/
│       ├── index.ts                             # Entry point
│       ├── config.ts                            # Environment config
│       ├── routes/
│       │   ├── health.ts                        # Health check endpoint
│       │   ├── upload.ts                        # S3 presigned URL
│       │   └── notifications.ts                 # FCM push via backend
│       └── services/
│           ├── s3.ts                            # Minio/S3 client
│           └── fcm.ts                           # Firebase Admin FCM
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

**Rules:**
- Never create files outside this structure without updating this document.
- Each feature follows Clean Architecture: `data/` → `domain/` → `presentation/`.
- Screen files go in `presentation/screens/` under each feature — never flat in `screens/`.
- BLoCs go in `presentation/bloc/` — one BLoC per feature.
- All Firebase interactions go through `data/datasources/` → `domain/repositories/` — screens never call Firestore directly.
- Reusable UI goes in `shared/widgets/` — one widget per file.
- Dependency injection setup lives in `injection_container.dart`.

---

## 5. Database Schema (Firestore)

### `locations` collection

```json
{
  "locationId": "auto-ID",
  "name": "Kantor Desa Cakrawala",
  "address": "Jl. Merdeka No. 17, Bandung",
  "adminId": "FK → hosts.hostId",
  "hostPhone": "081234567890",
  "qrCodeValue": "unique-qr-identifier",
  "createdAt": "Timestamp",
  "isActive": true
}
```

### `guests` collection

```json
{
  "guestId": "auto-ID",
  "name": "Budi Santoso",
  "phone": "081298765432",
  "email": "budi@example.com",
  "keperluan": "Meeting",
  "instansi": "PT Maju Jaya",
  "photoUrl": "https://storage.googleapis.com/...",
  "locationId": "FK → locations.locationId",
  "checkInTime": "Timestamp",
  "checkOutTime": "Timestamp | null",
  "hostPhone": "081234567890",
  "status": "checked_in"
}
```

**`keperluan` enum values:** `"Meeting"` | `"Personal"` | `"Kantor"` | `"Pengiriman"` | `"Lainnya"`

**`status` enum values:** `"checked_in"` | `"checked_out"`

### `hosts` collection

```json
{
  "hostId": "auto-ID",
  "name": "Admin Utama",
  "phone": "081234567890",
  "email": "admin@tamuku.app",
  "photoUrl": "https://storage.googleapis.com/... | null",
  "locations": ["locationId-1", "locationId-2"],
  "role": "admin",
  "createdAt": "Timestamp",
  "lastLogin": "Timestamp | null"
}
```

**`role` enum values:** `"admin"` | `"host"`

---

## 6. User Roles & Permissions

| Role | Authentication | Access |
|------|---------------|--------|
| **Guest** | None (unauthenticated) | Scan QR code, fill registration form, check-in, check-out |
| **Admin** | Firebase Auth (Email + Google) | Full CRUD on all locations, guests, settings; view dashboard; export data |
| **Host** | Firebase Auth (future phase) | View own location's guest list, receive notifications only |

**Permission rules:**
- Guest form is publicly writable — no auth required.
- Admin endpoints require valid Firebase Auth token.
- Firestore security rules enforce read/write per role.
- Host role is a **future enhancement** — do not implement yet.

---

## 7. Coding Standards

1. **Linting**: Run `flutter analyze` — must return 0 issues. Configuration in `analysis_options.yaml` with `flutter_lints` strict mode.
2. **`const` constructors**: Use `const` everywhere possible. Lint rule enforces this.
3. **State management**: All state via BLoC/Cubit pattern using `flutter_bloc`. **Never use `setState`** in screen widgets. **Never use Riverpod or Provider**.
4. **Widget pattern**: All screens are `StatelessWidget` wrapped with `BlocProvider` at the top. Use `BlocBuilder` for state-dependent UI, `BlocListener` for side effects, `BlocConsumer` when both are needed.
5. **Models/Entities**: Use `equatable` for all BLoC states, events, and domain entities. Use `freezed` + `json_serializable` for data models with `copyWith` support.
6. **Naming conventions** (Effective Dart):
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/functions: `camelCase`
   - Constants: `camelCase` (not SCREAMING_CAPS)
   - Private members: `_leadingUnderscore`
7. **Doc comments**: All public classes, methods, and top-level functions must have `///` doc comments.
8. **File length**: Maximum **300 lines** per file. Split longer files into logical parts.
9. **No hardcoded strings**: All user-facing text and configuration values go in `core/constants/app_constants.dart`.
10. **Indonesian UI text**: All user-facing strings must be in **Bahasa Indonesia**. Technical identifiers remain in English.
11. **Error handling**: All async operations must handle errors gracefully. Use `try-catch` with meaningful error messages.
12. **Imports order**: `dart:` → `package:flutter/` → `package:flutter_bloc/` → `package:firebase/` → relative imports. Separate groups with blank lines.
13. **BLoC pattern**: Each feature has its own BLoC with Event → State flow. BLoCs must NOT contain UI logic. Repositories handle data access. DataSources handle raw API/local calls.
14. **Offline-first**: All data writes must go to local storage first, then sync to Firebase when online. All reads must check local cache first, then fetch remote. Use `connectivity_plus` for network detection.
15. **StreamBuilder/FutureBuilder**: Use `StreamBuilder` for real-time Firestore listeners (guest list, dashboard stats). Use `FutureBuilder` for one-time operations (QR generation, settings load, CSV export).
16. **ListView.builder**: Always use `ListView.builder` for dynamic lists — never hardcode `ListView(children: [...])` for data-driven lists. Implement pagination for large datasets.

---

## 8. Testing Requirements

| Test Type | Scope | Target |
|-----------|-------|--------|
| **Unit tests** | All repositories, data sources, models, utils | 80%+ coverage |
| **BLoC tests** | All BLoCs (using `bloc_test` + `mocktail`) | All BLoC behaviors verified |
| **Widget tests** | All screens and key widgets | All screens covered |
| **Integration tests** | Critical user flows | Scan → Form → Submit → Confirm |

**Test file locations:**
- `test/unit/` — repository, data source, and model tests
- `test/bloc/` — BLoC unit tests (`bloc_test` package)
- `test/widget/` — screen and widget tests
- `test/integration/` — end-to-end flow tests

**Rules:**
- Every new repository/data source method must have a corresponding unit test.
- Every new BLoC must have bloc tests covering all event/state transitions.
- Every new screen must have a widget test.
- Critical paths (QR scan → check-in, admin login → dashboard) must have integration tests.
- Run `flutter test --coverage` before merging any feature branch.
- Never delete or skip existing tests without explicit approval.

---

## 9. Firebase Configuration

**Project**: `tamuku-app` (or team-chosen name)

**Services to enable:**
| Service | Purpose |
|---------|---------|
| Cloud Firestore | Primary database |
| Firebase Auth | Email/password + Google OAuth sign-in |
| Cloud Messaging (FCM) | Push notifications to admin devices |

**Replaced by Contabo VPS backend:**
| Service | Replacement |
|---------|-------------|
| Cloud Functions | ElysiaJS backend on Contabo VPS (FCM + WhatsApp API) |
| Firebase Storage | Contabo S3 (minio package in Flutter) |

**Firestore Security Rules:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Guests: readable by location admin, writable by anyone (guest form)
    match /guests/{guestId} {
      allow read: if request.auth != null;
      allow create: if true;  // guest form submission
      allow update, delete: if request.auth != null;
    }

    // Locations: admin-only CRUD
    match /locations/{locationId} {
      allow read: if true;  // QR code contains locationId
      allow write: if request.auth != null;
    }

    // Hosts: own profile only
    match /hosts/{hostId} {
      allow read, update: if request.auth != null && request.auth.uid == hostId;
      allow create: if request.auth != null;
      allow delete: if false;
    }
  }
}
```

**Storage Rules:**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /guests/{allPaths} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

**When schema changes, always update:**
1. This file (Section 5)
2. `firestore.rules`
3. `firestore.indexes.json` (if new queries require composite indexes)
4. Relevant model/entity classes in `lib/features/*/domain/entities/`

---

## 10. Agent Workflow Rules

Every AI agent working on this codebase MUST follow these rules:

1. **Read before write** — Always check existing code and this file before creating new files or modifying existing ones.
2. **Follow the folder structure** — Files go in the locations defined in Section 4. No flat dumps.
3. **BLoC only** — All state management through BLoC/Cubit. No `setState`, no `ChangeNotifier`, no Riverpod, no Provider.
4. **Test every service** — Write or update tests for any new repository/BLoC method before marking a feature complete.
5. **Update security rules** — If the Firestore schema changes, update `firestore.rules` and this document.
6. **No hardcoded strings** — Every user-facing string and config value belongs in `core/constants/app_constants.dart`.
7. **Indonesian UI** — All user-facing text in Bahasa Indonesia. Variable names, comments, and API identifiers in English.
8. **Commit format** — Use bracketed prefix: `[feature/auth] Add Google sign-in flow`, `[fix/qr] Fix scanner timeout`, `[docs] Update AGENTS.md`.
9. **Validate before declaring done** — Run `flutter analyze` and `flutter test` before marking any task complete.
10. **Update documentation** — If you change architecture, schema, or folder structure, update this AGENTS.md file.
11. **Widget diversity** — Every screen must demonstrate multiple Flutter widget categories (layout, scrolling, text, input, navigation). Avoid repeated patterns — show breadth of Flutter knowledge.
12. **Offline capability** — Any feature that reads/writes data must have a local storage fallback. Never assume internet connectivity.

---

## 11. Sprint Plan (4 Weeks)

| Week | Focus | Deliverables |
|------|-------|-------------|
| **W1** | Setup + Widget Foundations + Theme | Flutter project init, Firebase setup, theme system (DESIGN.md tokens), routing, `constants.dart`, demonstrate all widget categories (layout, scrolling, text, input, display, navigation, feedback) in scaffold screens. Implement `ListView.builder` in guest list. |
| **W2** | BLoC Architecture + Auth + Models | BLoC setup (`flutter_bloc`), dependency injection, Firebase Auth (email + Google), `AuthBloc` with events/states, data models with `equatable`, `FutureBuilder` for settings, `StreamBuilder` for real-time data, Firestore CRUD services. |
| **W3** | Features + Offline + Integration | `GuestBloc` + `LocationBloc`, Repository pattern, Firebase Remote + Local DataSources (Hive/SQLite offline cache), `connectivity_plus` for online/offline switching, QR scanner/generator, guest form → check-in flow, Contabo backend API (presigned URL upload + FCM push), WhatsApp API notification. |
| **W4** | Polish + Testing + SaaS Prep | Dashboard with `fl_chart`, CSV/PDF export, search & filter, BLoC unit tests (`bloc_test`), widget tests, integration tests (scan → form → submit → confirm), offline sync verification, UAT, bug fixes, final demo. |

**Definition of done per sprint:**
- All deliverables compile and pass `flutter analyze` with 0 issues
- All existing tests still pass
- New features have corresponding tests
- Sprint demo-ready on physical device or emulator

---

## 12. Quality Gates

Before ANY feature is marked "done," all checkboxes must pass:

- [ ] Code compiles without errors
- [ ] `flutter analyze` returns 0 issues
- [ ] All existing tests pass (`flutter test`)
- [ ] New tests written for new BLoC/repository/model code
- [ ] UI matches design specifications
- [ ] Firebase security rules updated if schema changed
- [ ] No hardcoded strings — all values in `app_constants.dart`
- [ ] All user-facing text is in Bahasa Indonesia
- [ ] File length under 300 lines
- [ ] Public APIs have doc comments
- [ ] AGENTS.md updated if architecture or schema changed
- [ ] Offline fallback implemented for data features
- [ ] Screen demonstrates multiple widget categories (layout, scrolling, text, input, navigation)

---

## 13. SaaS Preparation Notes

This project is designed as a university MVP that doubles as the foundation for a future SaaS product. Architecture decisions support this:

| Decision | SaaS Benefit |
|----------|-------------|
| BLoC over Riverpod | Cleaner separation of concerns, easier to onboard team members, industry-standard pattern for large apps |
| Repository pattern | Abstract data sources — swap Firebase for any backend without touching UI |
| Offline-first | Better UX in low-connectivity areas (Indonesian market reality) |
| Feature-based folder structure | Easy to extract features into separate packages/modules |
| Dependency injection | Testability, mock-friendly, environment-switching (dev/staging/prod) |
| equatable | Prevents unnecessary rebuilds, reduces bugs in state comparison |
| Clean Architecture layers | Domain layer can be reused across platforms (mobile, web, desktop) |
| Contabo VPS backend (ElysiaJS) | Self-hosted API avoids vendor lock-in, lower cost at scale, full control over notification pipeline |

### Future SaaS Enhancements (Post-MVP)
- Multi-tenant architecture (admin manages multiple organizations)
- Role-based access control (RBAC) with custom claims
- Web dashboard for analytics (React/Next.js)
- REST API for third-party integrations
- Stripe/Midtrans payment integration
- Custom branding per tenant
- Audit logging
- Data export API

---

## 14. Integration Map

| System | Location | Purpose |
|--------|----------|---------|
| **VS Code + GitHub Copilot** | `C:\Users\Fauzan\AppData\Roaming\Code\User\prompts` | AI-assisted development, agent instructions |
| **ObsidianVault** | `C:\Users\Fauzan\ObsidianVault\AI Memory\tamuku-project.md` | Project memory, decisions log |
| **Workbench** | `C:\Users\Fauzan\Workbench` | Raw notes, brainstorming |
| **Firebase Console** | console.firebase.google.com | Backend management, monitoring |
| **GitHub** | (to be created) | Version control, CI/CD |
| **Trello/Notion** | (optional) | Sprint board, task tracking |

---

## Appendix A: Key Contacts

| Name | NIM | Role |
|------|-----|------|
| Hafiz Nur Rizki | 24110300038 | Team Member |
| Ahmad Fauzan | 24110500007 | Team Member (Tech Lead) |
| Annur Syahrin Aisyah | 24110500014 | Team Member |
| Hedy Pamungkas, S.T., M.T.I | — | Supervisor |

**Course**: Mobile Computing
**University**: Universitas Cakrawala

---

## Appendix B: Useful Commands

```bash
# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build APK
flutter build apk --release

# Build iOS
flutter build ios

# Deploy Firestore rules
firebase deploy --only firestore:rules

# View Flutter dependencies
flutter pub deps

# Backend (Contabo VPS)
cd backend
bun install
bun run dev

# Build backend for production
cd backend
bun run build
```

---

*Last updated: 2026-07-06*
*Maintained by: AI Agent System + Ahmad Fauzan*
