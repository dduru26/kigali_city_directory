import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth/auth_controller.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 72),
            const SizedBox(height: 24),
            const Text(
              'A verification email has been sent to your email address. Please verify your email before accessing the app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .resendVerificationEmail();

                        if (context.mounted) {
                          final error = ref
                              .read(authControllerProvider)
                              .errorMessage;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error ?? 'Verification email sent again.',
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('Resend Verification Email'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .refreshUser();

                        if (context.mounted) {
                          final user = ref.read(authControllerProvider).user;
                          if (user != null && user.emailVerified) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email verified successfully.'),
                              ),
                            );
                          }
                        }
                      },
                child: const Text('I Have Verified My Email'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      await ref.read(authControllerProvider.notifier).logout();
                    },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
