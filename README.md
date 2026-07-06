# 🏛️ TamuKu — Buku Tamu Digital

> Aplikasi mobile Flutter untuk mencatat dan mengelola kunjungan tamu secara digital.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)
![BLoC](https://img.shields.io/badge/BLoC-8.x-0094F5?logo=bloc)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📖 Tentang TamuKu

TamuKu adalah aplikasi mobile berbasis Flutter yang menggantikan buku tamu konvensional dengan sistem digital berbasis QR code. Tamu cukup memindai QR code di lokasi, mengisi formulir registrasi singkat, dan data kunjungan otomatis tercatat secara real-time.

Admin dapat memantau kunjungan melalui dashboard mobile, menerima notifikasi Telegram saat tamu tiba, serta mengunduh data kunjungan dalam format CSV untuk keperluan pelaporan dan kepatuhan.

**Target waktu check-in: ≤ 30 detik** — dari pemindaian QR hingga data tercatat.

---

## ✨ Fitur Utama

### 👤 Tamu (Guest)
- Pemindaian QR code untuk akses form registrasi
- Formulir auto-fill untuk kunjungan berulang
- Check-in dan check-out dengan satu sentuhan
- Pelacakan durasi kunjungan otomatis
- Tidak perlu login atau registrasi akun

### 🔧 Admin
- **Dashboard** real-time — jumlah tamu hari ini, sedang berkunjung, sudah pulang
- **Daftar tamu** — pencarian, filter berdasarkan status/keperluan/tanggal
- **QR Generator** — buat dan cetak QR code untuk setiap lokasi
- **Ekspor CSV** — unduh data kunjungan untuk pelaporan
- **Notifikasi WhatsApp** — otomatis kirim pesan ke host saat tamu check-in
- **Multi-lokasi** — kelola beberapa lokasi dalam satu akun admin
- **Dark mode** — mode gelap untuk kenyamanan visual

### ⚙️ Technical
- **Offline-first** — data lokal tersimpan, disync saat online
- **Cross-platform** — Android dan iOS dari satu codebase
- **Real-time sync** — Firestore snapshot listener, perubahan langsung terlihat
- **Firebase backend** — Firestore, Auth, FCM, Storage, Cloud Functions

---

## 🎯 Target Pengguna

| Segmen | Kebutuhan |
|--------|-----------|
| RT/RW | Pencatatan kunjungan warga dan tamu |
| Masjid | Pencatatan jamaah tamu dan donatur |
| Kantor / Instansi | Registrasi tamu dan kunjungan dinas |
| Apartemen | Check-in penghuni dan tamu |
| Sekolah | Pencatatan kunjungan orang tua / tamu |
| Event / Pameran | Registrasi peserta dan pengunjung |

---

## 🛠️ Tech Stack

| Komponen | Teknologi | Versi |
|----------|-----------|-------|
| Bahasa | Dart | 3.x |
| Framework | Flutter | 3.x (latest stable) |
| State Management | flutter_bloc | 8.x |
| State Equivalence | equatable | 2.x |
| Database | Cloud Firestore | — |
| Local Storage | hive + sqflite | — |
| Authentication | Firebase Auth (Email + Google OAuth) | — |
| Push Notification | Firebase Cloud Messaging (FCM) | — |
| File Storage | Firebase Storage | — |
| QR Generation | qr_flutter | 4.x |
| QR Scanning | mobile_scanner | 5.x |
| Charts | fl_chart | — |
| Image Picker | image_picker | — |
| Network Detection | connectivity_plus | — |
| Image Caching | cached_network_image | — |
| Date Formatting | intl | — |
| Cloud Functions | Firebase Cloud Functions | — |
| Linting | flutter_lints + analysis_options.yaml | strict |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.x (latest stable channel)
- **Dart SDK** 3.x
- **Firebase Account** — [console.firebase.google.com](https://console.firebase.google.com)
- **Android Studio** atau **VS Code** dengan Flutter/Dart extensions
- **Git**

### Installation

```bash
# Clone repository
git clone https://github.com/[org]/tamuku.git
cd tamuku

# Install dependencies
flutter pub get

# Configure Firebase (interactive)
flutterfire configure

# Run the app
flutter run
```

### Firebase Setup

1. Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. Daftarkan aplikasi Android dan iOS
3. Enable layanan yang diperlukan:
   - **Cloud Firestore** — database utama
   - **Firebase Authentication** — Email/Password + Google Sign-In
   - **Firebase Storage** — penyimpanan foto tamu
   - **Cloud Messaging (FCM)** — push notification
   - **Cloud Functions** — trigger notifikasi saat data berubah
4. Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
5. Tempatkan file di lokasi yang sesuai:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
6. Deploy Firestore rules: `firebase deploy --only firestore:rules`

---

## 📁 Struktur Proyek

```
tamuku/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   ├── routes/
│   │   │   └── app_router.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── permissions.dart
│   │   └── errors/
│   │       ├── failures.dart
│   │       └── exceptions.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/datasources/
│   │   │   ├── data/repositories/
│   │   │   ├── domain/entities/
│   │   │   ├── domain/repositories/
│   │   │   └── presentation/bloc/
│   │   │   └── presentation/screens/
│   │   ├── guest/
│   │   │   ├── data/datasources/
│   │   │   ├── data/repositories/
│   │   │   ├── domain/entities/
│   │   │   ├── domain/repositories/
│   │   │   └── presentation/bloc/
│   │   │   └── presentation/screens/
│   │   ├── location/
│   │   │   ├── data/datasources/
│   │   │   ├── data/repositories/
│   │   │   ├── domain/entities/
│   │   │   ├── domain/repositories/
│   │   │   └── presentation/bloc/
│   │   │   └── presentation/screens/
│   │   └── notification/
│   │       ├── data/repositories/
│   │       ├── domain/repositories/
│   │       └── presentation/bloc/
│   │
│   ├── shared/
│   │   └── widgets/
│   │
│   └── injection_container.dart
│
├── assets/
│   ├── images/
│   │   └── logo.png
│   └── fonts/
│
├── test/
│   ├── unit/
│   ├── widget/
│   ├── bloc/
│   └── integration/
│
├── android/
├── ios/
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 📚 Dokumentasi

| Dokumen | Deskripsi |
|---------|-----------|
| [AGENTS.md](./AGENTS.md) | AI agent governance & coding standards |
| [DESIGN.md](./DESIGN.md) | Design system & visual identity |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Contribution guidelines *(to be created)* |

---

## 👥 Tim

| Nama | NIM | Peran |
|------|-----|-------|
| Hafiz Nur Rizki | 24110300038 | Team Member |
| Ahmad Fauzan | 24110500007 | Tech Lead |
| Annur Syahrin Aisyah | 24110500014 | Team Member |

**Dosen Pembimbing:** Hedy Pamungkas, S.T., M.T.I

**Mflutter_bloc Documentation](https://pub.dev/packages/flutter_bloc)
- [Equatable Documentation](https://pub.dev/packages/equatable
**Institusi:** Universitas Cakrawala — 2026

---

## 📖 Referensi

- [Flutter Documentation](https://docs.flutter.dev)
- [Dart Language](https://dart.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [FlutterFire Plugins](https://firebase.flutter.dev)
- [qr_flutter Package](https://pub.dev/packages/qr_flutter)
- [mobile_scanner Package](https://pub.dev/packages/mobile_scanner)
- [fl_chart Package](https://pub.dev/packages/fl_chart)

---

## 📄 License

Proyek ini dibuat untuk keperluan akademik (UAS Mobile Computing — Universitas Cakrawala, 2026).

Untuk penggunaan non-akademik, silakan hubungi tim pengembang.

---

*Dibuat oleh Tim Mobile Computing Kelompok 9 — Universitas Cakrawala, 2026*
