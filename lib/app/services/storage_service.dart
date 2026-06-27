import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  
  late SharedPreferences _prefs;
  
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  String? getToken() => _prefs.getString('token');
  Future<void> setToken(String token) => _prefs.setString('token', token);
  Future<void> removeToken() => _prefs.remove('token');
  
  String? getUserInfo() => _prefs.getString('userInfo');
  Future<void> setUserInfo(String info) => _prefs.setString('userInfo', info);

  // 权限管理
  List<String> getUserPermissions() {
    final perms = _prefs.getStringList('permissions');
    return perms ?? [];
  }

  Future<void> setUserPermissions(List<String> permissions) {
    return _prefs.setStringList('permissions', permissions);
  }

  Future<void> clearPermissions() => _prefs.remove('permissions');

  // 当前职员信息
  String? getCurrentStaffId() => _prefs.getString('staffId');
  Future<void> setCurrentStaffId(String id) => _prefs.setString('staffId', id);

  bool get isLoggedIn => getToken() != null;
}
