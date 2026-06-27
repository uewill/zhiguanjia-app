import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  static const String _tokenKey = 'auth_token';
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString(_tokenKey) ?? '';
  }

  Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    token.value = newToken;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    token.value = '';
  }

  bool get isLoggedIn => token.isNotEmpty;
}
