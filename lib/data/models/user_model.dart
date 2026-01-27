class UserModel {
  final String email;
  final String displayName;
  final String photoUrl;
  final String uid;
  final bool isAdmin;

  UserModel({
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    required this.uid,
    this.isAdmin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'uid': uid,
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      uid: json['uid'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }
}