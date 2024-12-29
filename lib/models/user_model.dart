class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final bool isOnline;
  final String? avatarUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.isOnline,
    this.avatarUrl,
  });

  // Convert Firebase document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '', // Retrieve fullName from Firestore
      avatarUrl: data['avatarUrl'] ?? '',
      isOnline: data['isOnline'] ?? false,
    );
  }

  // Convert UserModel to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName, // Save fullName to Firestore
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
    };
  }
}
