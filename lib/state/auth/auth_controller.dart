import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import 'auth_state.dart';
import '../../data/services/map_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(firestoreServiceProvider));
});

final currentUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return null;
  return ref.read(userRepositoryProvider).getUserProfile(user.uid);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges();
});

final mapServiceProvider = Provider<MapService>((ref) {
  return MapService();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      authRepository: ref.read(authRepositoryProvider),
      userRepository: ref.read(userRepositoryProvider),
    );
  },
);

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthController({required this.authRepository, required this.userRepository})
    : super(AuthState(user: authRepository.currentUser));

  // #region agent log (I’m using this for debugging)
  void _debugLog({
    required String runId,
    required String hypothesisId,
    required String location,
    required String message,
    Map<String, Object?> data = const {},
  }) {
    try {
      final payload = {
        'sessionId': 'c27c06',
        'runId': runId,
        'hypothesisId': hypothesisId,
        'location': location,
        'message': message,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      debugPrint('AGENT_LOG ${jsonEncode(payload)}');
    } catch (_) {}
  }
  // #endregion

  Future<bool> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // #region agent log (signup flow)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'A',
        location: 'auth_controller.dart:signUp',
        message: 'Sign up attempt (enter)',
        data: {
          'emailDomain':
              email.split('@').length == 2 ? email.split('@')[1] : 'invalid',
        },
      );
      // #endregion

      // #region agent log (calling FirebaseAuth)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'A',
        location: 'auth_controller.dart:signUp',
        message: 'Calling FirebaseAuth createUserWithEmailAndPassword',
      );
      // #endregion
      final credential = await authRepository.signUp(
        email: email,
        password: password,
      );
      // #region agent log (FirebaseAuth returned)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'A',
        location: 'auth_controller.dart:signUp',
        message: 'FirebaseAuth signUp returned',
        data: {'hasUser': credential.user != null},
      );
      // #endregion

      final user = credential.user;

      if (user != null) {
        // #region agent log (creating Firestore profile)
        _debugLog(
          runId: 'pre-fix',
          hypothesisId: 'C',
          location: 'auth_controller.dart:signUp',
          message: 'Creating Firestore user profile',
          data: {'uidPrefix': user.uid.length >= 6 ? user.uid.substring(0, 6) : user.uid},
        );
        // #endregion
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? email,
          createdAt: DateTime.now(),
          notificationsEnabled: false,
        );

        await userRepository.createUserProfile(appUser);
        // #region agent log (Firestore profile saved)
        _debugLog(
          runId: 'pre-fix',
          hypothesisId: 'C',
          location: 'auth_controller.dart:signUp',
          message: 'Firestore user profile created',
        );
        // #endregion

        // #region agent log (sending verification email)
        _debugLog(
          runId: 'pre-fix',
          hypothesisId: 'D',
          location: 'auth_controller.dart:signUp',
          message: 'Sending verification email',
        );
        // #endregion
        await authRepository.sendVerificationEmail();
        // #region agent log (verification call returned)
        _debugLog(
          runId: 'pre-fix',
          hypothesisId: 'D',
          location: 'auth_controller.dart:signUp',
          message: 'Verification email request returned',
        );
        // #endregion

        // #region agent log (reloading current user)
        _debugLog(
          runId: 'pre-fix',
          hypothesisId: 'E',
          location: 'auth_controller.dart:signUp',
          message: 'Reloading current user',
        );
        // #endregion
        await authRepository.reloadCurrentUser();
        // #region agent log (reload returned)
        _debugLog(
          runId: 'pre-fix',
          hypothesisId: 'E',
          location: 'auth_controller.dart:signUp',
          message: 'Reload current user returned',
          data: {
            'emailVerified': authRepository.currentUser?.emailVerified,
          },
        );
        // #endregion
        state = state.copyWith(
          isLoading: false,
          user: authRepository.currentUser,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User account could not be created.',
        );
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      // #region agent log (FirebaseAuthException)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'A',
        location: 'auth_controller.dart:signUp',
        message: 'FirebaseAuthException during sign up',
        data: {'code': e.code, 'message': e.message},
      );
      // #endregion
      state = state.copyWith(
        isLoading: false,
        errorMessage: '[${e.code}] ${e.message ?? 'Authentication error occurred.'}',
      );
      return false;
    } catch (e) {
      // #region agent log (non-Firebase exception)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'B',
        location: 'auth_controller.dart:signUp',
        message: 'Non-Firebase exception during sign up',
        data: {'errorType': e.runtimeType.toString()},
      );
      // #endregion
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // #region agent log (login flow)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'A',
        location: 'auth_controller.dart:login',
        message: 'Login attempt',
        data: {'emailDomain': email.split('@').length == 2 ? email.split('@')[1] : 'invalid'},
      );
      // #endregion
      await authRepository.login(email: email, password: password);
      await authRepository.reloadCurrentUser();

      state = state.copyWith(
        isLoading: false,
        user: authRepository.currentUser,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      // #region agent log (FirebaseAuthException)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'A',
        location: 'auth_controller.dart:login',
        message: 'FirebaseAuthException during login',
        data: {'code': e.code, 'message': e.message},
      );
      // #endregion
      state = state.copyWith(
        isLoading: false,
        errorMessage: '[${e.code}] ${e.message ?? 'Login failed.'}',
      );
      return false;
    } catch (e) {
      // #region agent log (non-Firebase exception)
      _debugLog(
        runId: 'pre-fix',
        hypothesisId: 'B',
        location: 'auth_controller.dart:login',
        message: 'Non-Firebase exception during login',
        data: {'errorType': e.runtimeType.toString()},
      );
      // #endregion
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await authRepository.sendVerificationEmail();
      state = state.copyWith(
        isLoading: false,
        user: authRepository.currentUser,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Could not send verification email.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> refreshUser() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await authRepository.reloadCurrentUser();
      state = state.copyWith(
        isLoading: false,
        user: authRepository.currentUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not refresh user status.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await authRepository.logout();
      state = const AuthState(isLoading: false, user: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Logout failed.');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
