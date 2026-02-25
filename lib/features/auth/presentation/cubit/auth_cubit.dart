import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whale_task/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isSigningUp = false;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(email: email, password: password);
      await _handleAuthStateSync();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        final isProfileCreated = await _authRepository.isProfileCreated(
          user.uid,
        );
        if (!isProfileCreated) {
          await _authRepository.createUserProfile(
            name: user.displayName ?? 'No Name',
            email: user.email ?? 'No Email',
            uid: user.uid,
          );
        }
        await _handleAuthStateSync();
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    emit(AuthLoading());
    _isSigningUp = true;
    try {
      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      await _authRepository.sendEmailVerification();
      emit(AuthNeedsVerification());
    } catch (e) {
      _isSigningUp = false;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _authRepository.sendEmailVerification();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkEmailVerification() async {
    emit(AuthLoading());
    try {
      await _authRepository.reloadUser();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _isSigningUp = false;
        await _handleAuthStateSync();
      } else {
        emit(
          const AuthError(
            'Email not verified. Please check your inbox and click the verification link.',
          ),
        );
        emit(AuthNeedsVerification());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _handleAuthStateSync() async {
    emit(AuthLoading());
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isSigningUp = false;
      emit(AuthUnauthenticated());
      return;
    }

    if (_isSigningUp) {
      if (!user.emailVerified) {
        emit(AuthNeedsVerification());
        return;
      } else {
        _isSigningUp = false;
      }
    }

    final isProfileCreated = await _authRepository.isProfileCreated(user.uid);
    if (isProfileCreated) {
      await _requestNotificationPermissions();
      emit(AuthAuthenticated(user));
      return;
    }

    await _authRepository.createUserProfile(
      name: user.displayName ?? 'No Name',
      email: user.email ?? 'No Email',
      uid: user.uid,
    );
    await _requestNotificationPermissions();
    emit(AuthAuthenticated(user));
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void checkAuthStatus() {
    _authRepository.user.listen((user) async {
      if (user != null) {
        await _handleAuthStateSync();
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
