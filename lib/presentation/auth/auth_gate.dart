import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth/auth_controller.dart';
import '../navigation/home_shell.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        return const HomeShell();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) =>
          const Scaffold(body: Center(child: Text('Something went wrong.'))),
    );
  }
}
