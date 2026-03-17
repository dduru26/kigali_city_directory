import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppUser.fromMap(doc.data()!);
  }

  Future<void> updateUserNotifications({
    required String uid,
    required bool notificationsEnabled,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'notificationsEnabled': notificationsEnabled});
  }

  Stream<List<ListingModel>> getAllListings() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<ListingModel>> getListingsByUser(String userId) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> createListing(ListingModel listing) async {
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .set(listing.toMap());
  }

  Future<void> updateListing(ListingModel listing) async {
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).delete();
  }
}
