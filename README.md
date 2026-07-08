# TamuKu — Buku Tamu Digital

> A modern digital guest book application for government offices, company reception desks, and public service locations.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Overview

TamuKu replaces traditional paper-based guest registration with a modern QR-code-based check-in/check-out system. Guests scan a QR code, fill a simple form, and check in — all within 30 seconds.

**Key Features:**
- 📱 QR code scan-to-check-in (no app download required for guests)
- 🔐 Admin dashboard with real-time guest tracking
- 📊 Analytics dashboard with charts and data export (CSV/Excel)
- 🔔 Instant push notifications (FCM + Telegram) when guests arrive
- 🌐 Offline-first architecture with automatic sync
- 🌙 Dark mode support

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x / Dart 3.x |
| State Management | flutter_bloc 8.x + equatable |
| Backend | ElysiaJS + Bun on Contabo VPS |
| Database | Cloud Firestore |
| Authentication | Firebase Auth (Email + Google) |
| Notifications | FCM + Telegram Bot API |
| Storage | Contabo S3 (MinIO) |
| Admin Web | React 19 + Vite + Tailwind CSS |
| Guest Web | Vanilla HTML/CSS/JS |

## Getting Started

### Prerequisites
- Flutter 3.x installed ([flutter.dev](https://flutter.dev))
- Dart 3.x
- Firebase project (free Spark plan works)
- Node.js 18+ (for admin web)
- Bun 1.x (for backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AhmadFauzanZW/TamuKu.git
   cd TamuKu
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication (Email/Password + Google)
   - Enable Cloud Firestore
   - Enable Cloud Messaging
   - Download `google-services.json` → `android/app/`
   - Download `GoogleService-Info.plist` → `ios/Runner/`

4. **Configure Backend**
   ```bash
   cd backend
   cp .env.example .env
   # Edit .env with your credentials
   bun install
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Backend Setup

```bash
cd backend
bun install
bun run dev
```

### Admin Web Setup

```bash
cd admin-web
cp .env.example .env
# Edit .env with your Firebase config
npm install
npm run dev
```

## Project Structure

```
tamuku/
├── lib/                          # Flutter source code
│   ├── core/                     # Theme, constants, routes, utils
│   ├── features/                 # Feature modules (Clean Architecture)
│   │   ├── auth/                 # Authentication (Firebase Auth + BLoC)
│   │   ├── guest/                # Guest management (CRUD + check-in/out)
│   │   ├── location/             # Location + QR + Dashboard
│   │   └── notification/         # FCM + Telegram notifications
│   └── shared/                   # Reusable widgets and services
├── backend/                      # ElysiaJS API server
│   ├── src/routes/               # API endpoints
│   └── src/services/             # S3, FCM, Telegram, Excel
├── admin-web/                    # React admin dashboard
└── test/                         # Unit, widget, and integration tests
```

## Architecture

```
Flutter App
├── Firebase Auth          → Authentication
├── Cloud Firestore        → Real-time database
├── FCM                    → Push notifications
├── Contabo S3 (MinIO)    → Guest photo storage
└── Contabo VPS (ElysiaJS) → Backend API
    ├── POST /api/guests/notify    → Host notification
    ├── POST /api/upload/url       → Presigned S3 URLs
    ├── POST /api/notifications/*  → FCM + Telegram
    └── GET  /api/export/guests    → Excel export

UI (Screen) → BLoC (Event → State) → Repository → DataSource (Remote + Local)
```

## Firestore Security Rules

See `firestore.rules` for the full ruleset. Key principles:
- Guest form submissions are publicly writable (no auth required)
- Admin operations require Firebase Auth
- Host profiles are only accessible by the owner

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [ElysiaJS](https://elysiajs.com)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
