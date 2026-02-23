import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFunctions? functions})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _functions = functions ?? FirebaseFunctions.instance {
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
  }

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Authenticate to get identity (ID Token)
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // 2. Get Authentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Authorize to get Access Token
      final GoogleSignInClientAuthorization authz = await googleUser
          .authorizationClient
          .authorizeScopes(['email', 'profile', 'openid']);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> createUserProfile({
    required String name,
    required String email,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('createUserProfile');
      await callable.call({'name': name, 'email': email, 'uid': uid});
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'Failed to create user profile.';
    } catch (e) {
      throw 'An unexpected error occurred while saving user data.';
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
