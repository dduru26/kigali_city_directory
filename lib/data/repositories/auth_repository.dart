import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  User? get currentUser => _authService.currentUser;

  Stream<User?> authStateChanges() {
    return _authService.authStateChanges();
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _authService.signUpWithEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _authService.loginWithEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendVerificationEmail() async {
    await _authService.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    await _authService.reloadUser();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
