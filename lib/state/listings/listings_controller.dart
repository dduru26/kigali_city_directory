import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/listing_model.dart';
import '../../data/repositories/listing_repository.dart';
import '../auth/auth_controller.dart';
import 'filter_controller.dart';
import 'listings_state.dart';

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(ref.read(firestoreServiceProvider));
});

final listingsControllerProvider =
    StateNotifierProvider<ListingsController, ListingsState>((ref) {
      return ListingsController(
        listingRepository: ref.read(listingRepositoryProvider),
        ref: ref,
      );
    });

final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  return ref.read(listingRepositoryProvider).getAllListings();
});

final myListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final user = ref.watch(authControllerProvider).user;

  if (user == null) {
    return Stream.value([]);
  }

  return ref.read(listingRepositoryProvider).getListingsByUser(user.uid);
});

final filteredListingsProvider = Provider<List<ListingModel>>((ref) {
  final listingsAsync = ref.watch(allListingsProvider);
  final filterState = ref.watch(filterControllerProvider);

  return listingsAsync.maybeWhen(
    data: (listings) {
      return listings.where((listing) {
        final matchesSearch = listing.name.toLowerCase().contains(
          filterState.searchQuery.toLowerCase(),
        );

        final matchesCategory =
            filterState.selectedCategory == 'All' ||
            listing.category == filterState.selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    },
    orElse: () => [],
  );
});

class ListingsController extends StateNotifier<ListingsState> {
  final ListingRepository listingRepository;
  final Ref ref;
  final Uuid _uuid = const Uuid();
  static const Duration _writeTimeout = Duration(seconds: 12);

  ListingsController({required this.listingRepository, required this.ref})
    : super(const ListingsState());

  Future<bool> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final user = ref.read(authControllerProvider).user;

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'You must be logged in to create a listing.',
        );
        return false;
      }

      final listing = ListingModel(
        id: _uuid.v4(),
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      try {
        await listingRepository.createListing(listing).timeout(_writeTimeout);
      } on TimeoutException {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              'Listing saved locally. It may take a moment to sync online.',
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Listing created successfully.',
      );

      return true;
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Failed to create listing.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create listing.',
      );
      return false;
    }
  }

  Future<bool> updateListing({
    required ListingModel existingListing,
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final updatedListing = existingListing.copyWith(
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        updatedAt: DateTime.now(),
      );

      try {
        await listingRepository
            .updateListing(updatedListing)
            .timeout(_writeTimeout);
      } on TimeoutException {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              'Update saved locally. It may take a moment to sync online.',
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Listing updated successfully.',
      );

      return true;
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Failed to update listing.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update listing.',
      );
      return false;
    }
  }

  Future<void> deleteListing(String listingId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      try {
        await listingRepository.deleteListing(listingId).timeout(_writeTimeout);
      } on TimeoutException {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              'Delete saved locally. It may take a moment to sync online.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Listing deleted successfully.',
      );
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Failed to delete listing.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete listing.',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
