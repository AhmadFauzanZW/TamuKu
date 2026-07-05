# 🏛️ TamuKu — Buku Tamu Digital

> Aplikasi mobile Flutter untuk mencatat dan mengelola kunjungan tamu secara digital.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📖 Tentang TamuKu

TamuKu adalah aplikasi mobile berbasis Flutter yang menggantikan buku tamu konvensional dengan sistem digital berbasis QR code. Tamu cukup memindai QR code di lokasi, mengisi formulir registrasi singkat, dan data kunjungan otomatis tercatat secara real-time.

Admin dapat memantau kunjungan melalui dashboard mobile, menerima notifikasi WhatsApp saat tamu tiba, serta mengunduh data kunjungan dalam format CSV untuk keperluan pelaporan dan kepatuhan.

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
| State Management | Riverpod | 2.x |
| Database | Cloud Firestore | — |
| Authentication | Firebase Auth (Email + Google OAuth) | — |
| Push Notification | Firebase Cloud Messaging (FCM) | — |
| File Storage | Firebase Storage | — |
| QR Generation | qr_flutter | 4.x |
| QR Scanning | mobile_scanner | 5.x |
| Charts | fl_chart | — |
| Image Picker | image_picker | — |
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

**Mata Kuliah:** Mobile Computing
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
