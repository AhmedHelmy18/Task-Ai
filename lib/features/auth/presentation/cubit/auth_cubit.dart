import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_ai/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
      await _requestNotificationPermissions();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _authRepository.createUserProfile(
          name: name,
          email: email,
          uid: user.uid,
        );
      }
      await _requestNotificationPermissions();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
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
    _authRepository.user.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
        _requestNotificationPermissions();
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
