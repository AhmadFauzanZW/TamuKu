import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  AuthBloc({
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  }) : _authRepository = authRepository,
       _prefs = prefs,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<_CachedSessionLoaded>(_onCachedSessionLoaded);
    _tryRestoreSession();
  }

  /// Attempts to restore a cached session from local storage.
  Future<void> _tryRestoreSession() async {
    final cached = await _authRepository.getCachedSession();
    if (!isClosed) {
      add(_CachedSessionLoaded(cached));
    }
  }

  Future<void> _onCachedSessionLoaded(
    _CachedSessionLoaded event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      // Store locationId BEFORE emitting so navigation screen can read it
      await _fetchAndStoreLocationId(event.user!.uid);
      if (!isClosed) emit(Authenticated(event.user!));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // CRITICAL: Store locationId BEFORE emitting Authenticated
      // so navigation screen can read it from SharedPreferences
      await _fetchAndStoreLocationId(user.uid);
      emit(Authenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Terjadi kesalahan tak terduga.'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      // CRITICAL: Store locationId BEFORE emitting Authenticated
      await _fetchAndStoreLocationId(user.uid);
      emit(Authenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Terjadi kesalahan tak terduga.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _prefs.remove(AppConstants.keyLocationId);
    await _authRepository.signOut();
    emit(AuthInitial());
  }

  /// Queries Firestore for the admin's locations and stores the first
  /// locationId in SharedPreferences. Falls back to any location if
  /// no match by adminId. Auto-creates a default location for first run.
  Future<void> _fetchAndStoreLocationId(String adminId) async {
    try {
      // 1. Try to find location by adminId
      var snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.locationsCollection)
          .where(AppConstants.fieldAdminId, isEqualTo: adminId)
          .limit(1)
          .get();

      // 2. Fallback: get ANY location
      if (snapshot.docs.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection(AppConstants.locationsCollection)
            .limit(1)
            .get();
      }

      // 3. Last resort: create default location for first-time admin
      if (snapshot.docs.isEmpty) {
        final docRef = await FirebaseFirestore.instance
            .collection(AppConstants.locationsCollection)
            .add({
              'name': 'Kantor Desa Cakrawala',
              'address': 'Jl. Merdeka No. 17, Bandung',
              'adminId': adminId,
              'hostPhone': '081234567890',
              'qrCodeValue': '',
              'createdAt': FieldValue.serverTimestamp(),
              'isActive': true,
            });
        await _prefs.setString(AppConstants.keyLocationId, docRef.id);
        return;
      }

      // 4. Store existing location
      await _prefs.setString(
        AppConstants.keyLocationId,
        snapshot.docs.first.id,
      );
    } catch (_) {
      // Silently fail — screens will show empty state
    }
  }
}

/// Internal event for delivering cached session data to the bloc.
class _CachedSessionLoaded extends AuthEvent {
  final UserEntity? user;
  const _CachedSessionLoaded(this.user);
  @override
  List<Object> get props => [user ?? ''];
}
