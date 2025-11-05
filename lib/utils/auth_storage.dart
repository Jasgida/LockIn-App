import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _emailKey = 'user_email';
  static const _passwordKey = 'user_password';

  // ✅ Save credentials locally
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  // ✅ Get credentials
  static Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final password = prefs.getString(_passwordKey);
    return {'email': email, 'password': password};
  }

  // ✅ Clear credentials
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}
