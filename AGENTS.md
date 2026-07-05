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
│            │   Riverpod     │                      │
│            │   State Mgmt   │                      │
│            └───────┬────────┘                      │
│                    │                               │
│            ┌───────▼────────┐                      │
│            │   Services     │                      │
│            │   Layer        │                      │
│            └───────┬────────┘                      │
└────────────────────┼─────────────────────────────┘
                     │
          ┌──────────▼──────────┐
          │   Firebase Backend   │
          │                      │
          │  • Firestore (DB)    │
          │  • Auth (Email+Goog) │
          │  • Storage (Photos)  │
          │  • FCM (Notif)       │
          │  • Analytics         │
          │  • Cloud Functions   │
          └──────────────────────┘
```

**Two user flows:**
1. **Guest (Unauthenticated)** — QR scan → form → check-in/out. No login required.
2. **Admin (Authenticated)** — Email/Google sign-in → full dashboard with CRUD operations.

**Notification pipeline:**
- Guest checks in → Firestore write → Cloud Function triggers → FCM push + WhatsApp API message to host phone.

---

## 3. Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Dart | 3.x |
| Framework | Flutter | 3.x (latest stable) |
| State Management | Riverpod | 2.x |
| Backend | Firebase | Latest |
| Database | Cloud Firestore | — |
| Authentication | Firebase Auth (Email + Google OAuth) | — |
| QR Generation | qr_flutter | 4.x |
| QR Scanning | mobile_scanner | 5.x |
| Image Picker | image_picker | — |
| File Storage | Firebase Storage | — |
| Notifications | FCM + WhatsApp Business API | — |
| Analytics | Firebase Analytics | — |
| Linting | flutter_lints + analysis_options.yaml | strict |
| Code Gen (optional) | freezed + json_serializable | — |

---

## 4. Folder Structure

```
tamuku/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart
│   │   ├── routes.dart
│   │   └── constants.dart
│   ├── models/
│   │   ├── guest.dart
│   │   ├── location.dart
│   │   └── host.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── guest_provider.dart
│   │   ├── location_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── guest/
│   │   │   ├── scan_screen.dart
│   │   │   ├── guest_form_screen.dart
│   │   │   ├── confirmation_screen.dart
│   │   │   ├── checkout_screen.dart
│   │   │   └── error_screen.dart
│   │   └── admin/
│   │       ├── login_screen.dart
│   │       ├── dashboard_screen.dart
│   │       ├── guest_list_screen.dart
│   │       ├── qr_generator_screen.dart
│   │       └── settings_screen.dart
│   ├── services/
│   │   ├── firestore_service.dart
│   │   ├── auth_service.dart
│   │   ├── qr_service.dart
│   │   ├── notification_service.dart
│   │   ├── whatsapp_service.dart
│   │   └── export_service.dart
│   ├── widgets/
│   │   ├── guest_tile.dart
│   │   ├── stat_card.dart
│   │   ├── search_bar.dart
│   │   ├── filter_chips.dart
│   │   └── app_drawer.dart
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── permissions.dart
├── assets/
│   ├── images/
│   │   └── logo.png
│   └── fonts/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── android/
├── ios/
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

**Rules:**
- Never create files outside this structure without updating this document.
- Screen files go in `screens/guest/` or `screens/admin/` — never flat in `screens/`.
- All Firebase interactions go through `services/` — screens never call Firestore directly.
- Reusable UI goes in `widgets/` — one widget per file.

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
3. **State management**: All state via Riverpod providers. **Never use `setState`** in screen widgets.
4. **Widget pattern**: All screens are `StatelessWidget` with `ConsumerWidget` or `ConsumerStatefulWidget` from Riverpod.
5. **Models**: Use `freezed` + `json_serializable` for immutable data classes with `copyWith`. If not using codegen, implement manual `copyWith`.
6. **Naming conventions** (Effective Dart):
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/functions: `camelCase`
   - Constants: `camelCase` (not SCREAMING_CAPS)
   - Private members: `_leadingUnderscore`
7. **Doc comments**: All public classes, methods, and top-level functions must have `///` doc comments.
8. **File length**: Maximum **300 lines** per file. Split longer files into logical parts.
9. **No hardcoded strings**: All user-facing text and configuration values go in `config/constants.dart`.
10. **Indonesian UI text**: All user-facing strings must be in **Bahasa Indonesia**. Technical identifiers remain in English.
11. **Error handling**: All async operations must handle errors gracefully. Use `try-catch` with meaningful error messages.
12. **Imports order**: `dart:` → `package:flutter/` → `package:riverpod/` → `package:firebase/` → relative imports. Separate groups with blank lines.

---

## 8. Testing Requirements

| Test Type | Scope | Target |
|-----------|-------|--------|
| **Unit tests** | All services, models, utils | 80%+ coverage |
| **Widget tests** | All screens and key widgets | All screens covered |
| **Integration tests** | Critical user flows | Scan → Form → Submit → Confirm |

**Test file locations:**
- `test/unit/` — service and model tests
- `test/widget/` — screen and widget tests
- `test/integration/` — end-to-end flow tests

**Rules:**
- Every new service method must have a corresponding unit test.
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
| Firebase Storage | Guest photo uploads |
| Cloud Functions | Trigger notifications on Firestore writes |
| Cloud Messaging (FCM) | Push notifications to admin devices |
| Firebase Analytics | Usage tracking |

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
4. Relevant model classes in `lib/models/`

---

## 10. Agent Workflow Rules

Every AI agent working on this codebase MUST follow these rules:

1. **Read before write** — Always check existing code and this file before creating new files or modifying existing ones.
2. **Follow the folder structure** — Files go in the locations defined in Section 4. No flat dumps.
3. **Riverpod only** — All state management through Riverpod providers. No `setState`, no `ChangeNotifier` (unless wrapping legacy code).
4. **Test every service** — Write or update tests for any new service method before marking a feature complete.
5. **Update security rules** — If the Firestore schema changes, update `firestore.rules` and this document.
6. **No hardcoded strings** — Every user-facing string and config value belongs in `config/constants.dart`.
7. **Indonesian UI** — All user-facing text in Bahasa Indonesia. Variable names, comments, and API identifiers in English.
8. **Commit format** — Use bracketed prefix: `[feature/auth] Add Google sign-in flow`, `[fix/qr] Fix scanner timeout`, `[docs] Update AGENTS.md`.
9. **Validate before declaring done** — Run `flutter analyze` and `flutter test` before marking any task complete.
10. **Update documentation** — If you change architecture, schema, or folder structure, update this AGENTS.md file.

---

## 11. Sprint Plan (4 Weeks)

| Week | Focus | Deliverables |
|------|-------|-------------|
| **W1** | Setup + UI Design | Flutter project init, Firebase project setup, all screen layouts, theme system, routing, `constants.dart` |
| **W2** | Auth + Database | Firebase Auth (email + Google), Firestore CRUD services, data models with freezed, Riverpod providers, unit tests for services |
| **W3** | Integration + Scan | QR scanner (`mobile_scanner`), QR generator (`qr_flutter`), guest form submission, FCM notification pipeline, WhatsApp Business API integration, Cloud Functions |
| **W4** | Polish + Testing | Dashboard statistics, CSV/PDF export, search & filter, end-to-end testing, UAT, bug fixes, final demo preparation |

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
- [ ] New tests written for new service/model code
- [ ] UI matches design specifications
- [ ] Firebase security rules updated if schema changed
- [ ] No hardcoded strings — all values in `constants.dart`
- [ ] All user-facing text is in Bahasa Indonesia
- [ ] File length under 300 lines
- [ ] Public APIs have doc comments
- [ ] AGENTS.md updated if architecture or schema changed

---

## 13. Integration Map

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

# Deploy Cloud Functions
firebase deploy --only functions

# View Flutter dependencies
flutter pub deps
```

---

*Last updated: 2026-07-05*
*Maintained by: AI Agent System + Ahmad Fauzan*
