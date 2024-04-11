class UserModel {
  final String? avatarUrl;

  UserModel({this.avatarUrl});

  factory UserModel.fromFirestore(Map<String, dynamic> firestoreData) {
    return UserModel(
      avatarUrl: firestoreData['avatarUrl'] as String?,
    );
  }
}
