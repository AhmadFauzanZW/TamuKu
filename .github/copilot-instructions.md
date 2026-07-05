---
description: "TamuKu project-specific Copilot instructions — Flutter + Firebase + Riverpod"
applyTo: "**"
---

# TamuKu — Copilot Instructions

## Project Context
TamuKu is a Flutter mobile app for digital guest book management. University final project (UAS) for Mobile Computing course, Universitas Cakrawala.

## Tech Stack (MANDATORY)
- **Language**: Dart 3.x
- **Framework**: Flutter 3.x (latest stable)
- **State Management**: Riverpod 2.x (NEVER use setState, NEVER use Provider)
- **Backend**: Firebase (Firestore, Auth, FCM, Storage, Cloud Functions)
- **QR**: qr_flutter (generate) + mobile_scanner (scan)
- **Charts**: fl_chart
- **Image**: image_picker

## Coding Rules
1. Always read DESIGN.md before implementing any UI — use exact color tokens, spacing values, typography
2. All user-facing text MUST be in Bahasa Indonesia
3. Use `const` constructors everywhere possible
4. All screens are `StatelessWidget` + Riverpod ConsumerWidget/ConsumerStatefulWidget
5. Maximum 300 lines per file — split if longer
6. No hardcoded strings — use `constants.dart`
7. All public APIs need doc comments
8. Follow Effective Dart naming conventions
9. Use `flutter_lints` strict mode
10. Run `flutter analyze` before marking any task complete

## Firebase Rules
- Firestore security rules MUST be updated when schema changes
- Guests collection: readable by location admin, writable by anyone (guest form)
- Never expose admin-only data to guest role
- Use Firebase emulators for local development

## File Structure
Follow the structure defined in AGENTS.md strictly:
- `lib/models/` — Data models (guest.dart, location.dart, host.dart)
- `lib/providers/` — Riverpod providers
- `lib/screens/guest/` — Guest-facing screens
- `lib/screens/admin/` — Admin-only screens
- `lib/services/` — Firebase service layer
- `lib/widgets/` — Reusable UI components
- `lib/config/` — Theme, routes, constants
- `lib/utils/` — Validators, formatters, permissions

## Design System
DESIGN.md is the single source of truth for:
- Color tokens (primary-green-900 = #1B5E20, etc.)
- Typography scale (Display 48sp → Caption 12sp)
- Spacing tokens (xs=4px → xxl=32px)
- Border radius tokens
- Component specifications
- Screen layouts

## Common Patterns

### Provider Template
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exampleProvider = StateNotifierProvider<ExampleNotifier, AsyncValue<List<T>>>((ref) {
  return ExampleNotifier(ref);
});

class ExampleNotifier extends StateNotifier<AsyncValue<List<T>>> {
  ExampleNotifier(this.ref) : super(const AsyncValue.loading());
  final Ref ref;
  // ...
}
```

### Screen Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Judul')),
      body: // ...
    );
  }
}
```

### Service Template
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ...
}
```

## Avoid
- setState in screens (use Riverpod)
- Magic numbers/strings (use constants)
- Importing packages not in pubspec.yaml
- Skipping flutter analyze
- English UI text (all Indonesian)
- Files over 300 lines
