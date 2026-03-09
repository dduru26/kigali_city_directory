import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/listing_model.dart';
import '../../state/auth/auth_controller.dart';

class ListingDetailScreen extends ConsumerWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLng listingLocation = LatLng(listing.latitude, listing.longitude);

    final Set<Marker> markers = {
      Marker(
        markerId: MarkerId(listing.id),
        position: listingLocation,
        infoWindow: InfoWindow(title: listing.name, snippet: listing.category),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(listing.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _InfoTile(label: 'Category', value: listing.category),
          _InfoTile(label: 'Address', value: listing.address),
          _InfoTile(label: 'Contact Number', value: listing.contactNumber),
          _InfoTile(label: 'Description', value: listing.description),
          _InfoTile(label: 'Latitude', value: listing.latitude.toString()),
          _InfoTile(label: 'Longitude', value: listing.longitude.toString()),
          const SizedBox(height: 20),
          Text(
            'Location on Map',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: listingLocation,
                  zoom: 15,
                ),
                markers: markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final success = await ref
                    .read(mapServiceProvider)
                    .openDirections(
                      latitude: listing.latitude,
                      longitude: listing.longitude,
                    );

                if (context.mounted && !success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open directions.')),
                  );
                }
              },
              icon: const Icon(Icons.directions),
              label: const Text('Open Directions'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
