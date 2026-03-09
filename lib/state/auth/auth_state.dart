import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const AuthState({this.isLoading = false, this.errorMessage, this.user});

  bool get isAuthenticated => user != null;
  bool get isVerified => user?.emailVerified ?? false;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }
}
