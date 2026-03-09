import '../models/listing_model.dart';
import '../services/firestore_service.dart';

class ListingRepository {
  final FirestoreService _firestoreService;

  ListingRepository(this._firestoreService);

  Stream<List<ListingModel>> getAllListings() {
    return _firestoreService.getAllListings();
  }

  Stream<List<ListingModel>> getListingsByUser(String userId) {
    return _firestoreService.getListingsByUser(userId);
  }

  Future<void> createListing(ListingModel listing) async {
    await _firestoreService.createListing(listing);
  }

  Future<void> updateListing(ListingModel listing) async {
    await _firestoreService.updateListing(listing);
  }

  Future<void> deleteListing(String listingId) async {
    await _firestoreService.deleteListing(listingId);
  }
}
