class UserModel {
  final String email;
  final String displayName;
  final String photoUrl;
  final String uid;
  final bool isAdmin;
  /// Shop name when user is a seller. Empty means no shop created yet.
  final String shopName;
  /// Shop display image URL (e.g. from Cloudinary).
  final String shopDisplayPicUrl;
  /// Shop category for filtering/browsing (e.g. "Electronics", "Home").
  final String shopCategory;

  UserModel({
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    required this.uid,
    this.isAdmin = false,
    this.shopName = '',
    this.shopDisplayPicUrl = '',
    this.shopCategory = '',
  });

  /// True if the user has completed create-shop (has a shop name set).
  bool get hasShop => shopName.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'uid': uid,
      'isAdmin': isAdmin,
      'shopName': shopName,
      'shopDisplayPicUrl': shopDisplayPicUrl,
      'shopCategory': shopCategory,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      uid: json['uid'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      shopName: json['shopName'] ?? '',
      shopDisplayPicUrl: json['shopDisplayPicUrl'] ?? '',
      shopCategory: json['shopCategory'] ?? '',
    );
  }
}