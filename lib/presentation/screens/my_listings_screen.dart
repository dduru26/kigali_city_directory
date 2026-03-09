import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing_model.dart';
import '../../state/auth/auth_controller.dart';
import '../../state/listings/listings_controller.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String listingId,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Listing'),
            content: const Text(
              'Are you sure you want to delete this listing?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    await ref
        .read(listingsControllerProvider.notifier)
        .deleteListing(listingId);

    if (context.mounted) {
      final state = ref.read(listingsControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ??
                state.successMessage ??
                'Delete operation completed.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myListingsAsync = ref.watch(myListingsProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: user == null
          ? const Center(child: Text('You must be logged in.'))
          : myListingsAsync.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return const Center(
                    child: Text('You have not created any listings yet.'),
                  );
                }

                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return _MyListingCard(
                      listing: listing,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditListingScreen(listing: listing),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(context, ref, listing.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Failed to load your listings.')),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MyListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyListingCard({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(listing.name),
        subtitle: Text('${listing.category} • ${listing.address}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
