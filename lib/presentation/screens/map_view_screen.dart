import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/listing_model.dart';
import '../../state/listings/listings_controller.dart';

class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(allListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(
              child: Text('No listings available on the map.'),
            );
          }

          final firstListing = listings.first;
          final initialPosition = LatLng(
            firstListing.latitude,
            firstListing.longitude,
          );

          final markers = _buildMarkers(listings);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load map data.')),
      ),
    );
  }

  Set<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(title: listing.name, snippet: listing.category),
      );
    }).toSet();
  }
}
