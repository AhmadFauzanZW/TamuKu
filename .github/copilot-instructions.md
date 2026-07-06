---
description: "TamuKu project-specific Copilot instructions — Flutter + Firebase + BLoC"
applyTo: "**"
---

# TamuKu — Copilot Instructions

## Project Context
TamuKu is a Flutter mobile app for digital guest book management. University final project (UAS) for Mobile Computing course, Universitas Cakrawala. Designed as SaaS-ready MVP.

## Tech Stack (MANDATORY)
- **Language**: Dart 3.x
- **Framework**: Flutter 3.x (latest stable)
- **State Management**: flutter_bloc 8.x (NEVER use setState, NEVER use Provider, NEVER use Riverpod)
- **State Equivalence**: equatable 2.x (required for all BLoC states and events)
- **Backend**: Firebase (Firestore, Auth, FCM)
- **Backend API**: ElysiaJS + Bun on Contabo VPS (replaces Cloud Functions + Firebase Storage)
- **API Client**: http package (for Contabo backend calls)
- **Local Storage**: hive + sqflite (offline fallback)
- **QR**: qr_flutter (generate) + mobile_scanner (scan)
- **Charts**: fl_chart
- **Image**: image_picker
- **Network**: connectivity_plus (online/offline detection)
- **Caching**: cached_network_image
- **Notifications**: firebase_messaging (FCM) + Telegram Bot API (via backend)

## Coding Rules
1. Always read DESIGN.md before implementing any UI — use exact color tokens, spacing values, typography
2. All user-facing text MUST be in Bahasa Indonesia
3. Use `const` constructors everywhere possible
4. All screens are `StatelessWidget` + `BlocProvider` at top + `BlocBuilder`/`BlocListener`/`BlocConsumer`
5. Maximum 300 lines per file — split if longer
6. No hardcoded strings — use `app_constants.dart`
7. All public APIs need doc comments
8. Follow Effective Dart naming conventions
9. Use `flutter_lints` strict mode
10. Run `flutter analyze` before marking any task complete
11. Every screen must demonstrate multiple Flutter widget categories (layout, scrolling, text, input, navigation)
12. All data writes go to local storage first, then sync to Firebase when online
13. Always use `ListView.builder` for dynamic lists — never hardcode children

## Architecture: Clean Architecture + BLoC

```
UI (Screen) → BLoC (Event → State) → Repository → DataSource (Remote + Local)
```

### Feature Structure
```
lib/features/[feature]/
├── data/
│   ├── datasources/     # Remote (Firebase) + Local (Hive/SQLite)
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business objects (equatable)
│   └── repositories/    # Abstract repository interfaces
└── presentation/
    ├── bloc/            # BLoC, Events, States
    └── screens/         # UI widgets
```

## File Structure
- `lib/core/` — Theme, constants, routes, utils, errors
- `lib/features/` — Feature modules (auth, guest, location, notification)
- `lib/shared/widgets/` — Reusable UI components
- `lib/shared/services/` — API client, S3 config
- `lib/injection_container.dart` — Dependency injection (get_it)

## Design System
DESIGN.md is the single source of truth for:
- Color tokens (primary-green-900 = #1B5E20, etc.)
- Typography scale (Display 48sp → Caption 12sp)
- Spacing tokens (xs=4px → xxl=32px)
- Border radius tokens
- Component specifications
- Screen layouts

## Common Patterns

### BLoC Template
```dart
// auth_event.dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

// auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object> get props => [user];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(email: event.email, password: event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

### Screen Template
```dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const CircularProgressIndicator();
        }
        return Scaffold(/* ... */);
      },
    );
  }
}
```

### Repository Template
```dart
abstract class GuestRepository {
  Future<Either<Failure, List<GuestEntity>>> getGuests(String locationId);
  Future<Either<Failure, void>> checkIn(GuestEntity guest);
  Future<Either<Failure, void>> checkOut(String guestId);
  Stream<List<GuestEntity>> watchGuests(String locationId);
}

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDataSource remote;
  final GuestLocalDataSource local;
  final NetworkInfo networkInfo;

  GuestRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<GuestEntity>>> getGuests(String locationId) async {
    if (await networkInfo.isConnected) {
      try {
        final guests = await remote.getGuests(locationId);
        await local.cacheGuests(guests);
        return Right(guests);
      } catch (e) {
        final cached = await local.getCachedGuests(locationId);
        return cached.isNotEmpty ? Right(cached) : Left(ServerFailure());
      }
    } else {
      final cached = await local.getCachedGuests(locationId);
      return cached.isNotEmpty ? Right(cached) : Left(CacheFailure());
    }
  }
}
```

## Firebase Rules
- Firestore security rules MUST be updated when schema changes
- Guests collection: readable by location admin, writable by anyone (guest form)
- Never expose admin-only data to guest role
- Use Firebase emulators for local development

## Avoid
- setState in screens (use BLoC)
- Riverpod, Provider, ChangeNotifier
- Magic numbers/strings (use app_constants.dart)
- Importing packages not in pubspec.yaml
- Skipping flutter analyze
- English UI text (all Indonesian)
- Files over 300 lines
- `ListView(children: [...])` for dynamic data (use `ListView.builder`)
- Assuming internet connectivity (always offline-first)
