class AppUser {
  final String uid;
  final String email;
  final DateTime createdAt;
  final bool notificationsEnabled;

  AppUser({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.notificationsEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      notificationsEnabled: map['notificationsEnabled'] ?? false,
    );
  }
}
