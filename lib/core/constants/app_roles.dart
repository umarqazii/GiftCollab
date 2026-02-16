/// User role identifiers stored in preferences and used across the app.
class AppRoles {
  const AppRoles._();

  static const String eventManagement = 'event_management';
  static const String sellerManagement = 'seller_management';

  static bool isEventManagement(String? role) => role == eventManagement;

  static bool isSellerManagement(String? role) => role == sellerManagement;
}