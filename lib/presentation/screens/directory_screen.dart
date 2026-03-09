import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing_model.dart';
import '../../state/listings/filter_controller.dart';
import '../../state/listings/listings_controller.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(allListingsProvider);
    final filteredListings = ref.watch(filteredListingsProvider);
    final filterState = ref.watch(filterControllerProvider);

    const categories = [
      'All',
      'Hospital',
      'Police Station',
      'Library',
      'Restaurant',
      'Café',
      'Park',
      'Tourist Attraction',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref
                    .read(filterControllerProvider.notifier)
                    .updateSearchQuery(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: filterState.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filter by category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(filterControllerProvider.notifier)
                      .updateCategory(value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: listingsAsync.when(
              data: (_) {
                if (filteredListings.isEmpty) {
                  return const Center(child: Text('No listings found.'));
                }

                return ListView.builder(
                  itemCount: filteredListings.length,
                  itemBuilder: (context, index) {
                    final listing = filteredListings[index];
                    return _ListingCard(listing: listing);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Failed to load listings.')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(listing.name),
        subtitle: Text('${listing.category} • ${listing.address}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          );
        },
      ),
    );
  }
}
