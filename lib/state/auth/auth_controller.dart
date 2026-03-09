import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import 'auth_state.dart';

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

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges();
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

  Future<bool> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final credential = await authRepository.signUp(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? email,
          createdAt: DateTime.now(),
          notificationsEnabled: false,
        );

        await userRepository.createUserProfile(appUser);
        await authRepository.sendVerificationEmail();

        await authRepository.reloadCurrentUser();
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Authentication error occurred.',
      );
      return false;
    } catch (e) {
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
      await authRepository.login(email: email, password: password);
      await authRepository.reloadCurrentUser();

      state = state.copyWith(
        isLoading: false,
        user: authRepository.currentUser,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Login failed.',
      );
      return false;
    } catch (e) {
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
