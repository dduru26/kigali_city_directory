import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? 'No user logged in'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            profileAsync.when(
              data: (profile) {
                final enabled = profile?.notificationsEnabled ?? false;
                final canToggle = user != null;

                return SwitchListTile(
                  value: enabled,
                  onChanged: canToggle
                      ? (value) async {
                          await ref
                              .read(userRepositoryProvider)
                              .updateUserNotifications(
                                uid: user!.uid,
                                notificationsEnabled: value,
                              );
                        }
                      : null,
                  title: const Text('Enable location-based notifications'),
                  subtitle: const Text(
                    'Stored in your profile (Firestore)',
                  ),
                );
              },
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading preferences...'),
              ),
              error: (_, __) => const ListTile(
                leading: Icon(Icons.error_outline),
                title: Text('Could not load preferences'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
