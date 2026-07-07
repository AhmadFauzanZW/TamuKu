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
  })  : _authRepository = authRepository,
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

  void _onCachedSessionLoaded(
    _CachedSessionLoaded event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
      // Ensure locationId is stored (may be missing from older sessions)
      _fetchAndStoreLocationId(event.user!.uid);
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
      emit(Authenticated(user));

      // Fetch and store the admin's locationId
      await _fetchAndStoreLocationId(user.uid);
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
      emit(Authenticated(user));

      // Fetch and store the admin's locationId
      await _fetchAndStoreLocationId(user.uid);
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
  /// locationId in SharedPreferences. Silently fails if no locations found.
  Future<void> _fetchAndStoreLocationId(String adminId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.locationsCollection)
          .where(AppConstants.fieldAdminId, isEqualTo: adminId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final locationId = snapshot.docs.first.id;
        await _prefs.setString(AppConstants.keyLocationId, locationId);
      }
    } catch (_) {
      // Silently fail — guest list will show empty state
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
