import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  static const String _keyUserRole = 'user_role';

  Future<void> saveRole(String role) async {
    await _prefs.setString(_keyUserRole, role);
  }

  String? getRole() {
    return _prefs.getString(_keyUserRole);
  }
}