import 'package:flutter/material.dart';

import '../../data/models/listing_model.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              listing.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('Category: ${listing.category}'),
            const SizedBox(height: 8),
            Text('Address: ${listing.address}'),
            const SizedBox(height: 8),
            Text('Contact: ${listing.contactNumber}'),
            const SizedBox(height: 8),
            Text('Description: ${listing.description}'),
            const SizedBox(height: 8),
            Text('Latitude: ${listing.latitude}'),
            const SizedBox(height: 8),
            Text('Longitude: ${listing.longitude}'),
          ],
        ),
      ),
    );
  }
}
