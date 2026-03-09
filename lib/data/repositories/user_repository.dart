import '../models/app_user.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository(this._firestoreService);

  Future<void> createUserProfile(AppUser user) async {
    await _firestoreService.createUserProfile(user);
  }

  Future<AppUser?> getUserProfile(String uid) async {
    return await _firestoreService.getUserProfile(uid);
  }
}
