import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存服务 - 本地数据缓存
class CacheService extends GetxService {
  static CacheService get to => Get.find();
  
  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  
  /// 初始化
  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  /// 内存缓存 - 读取
  T? getMemory<T>(String key) {
    return _memoryCache[key] as T?;
  }
  
  /// 内存缓存 - 写入
  void setMemory<T>(String key, T value) {
    _memoryCache[key] = value;
  }
  
  /// 获取所有内存缓存键
  List<String> getMemoryKeys() {
    return _memoryCache.keys.toList();
  }
  
  /// 内存缓存 - 删除
  void removeMemory(String key) {
    _memoryCache.remove(key);
  }
  
  /// 内存缓存 - 清空
  void clearMemory() {
    _memoryCache.clear();
  }
  
  /// 本地缓存 - 读取
  String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  /// 本地缓存 - 写入
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  /// 本地缓存 - 读取JSON
  Map<String, dynamic>? getJson(String key) {
    final jsonStr = getString(key);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// 本地缓存 - 写入JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }
  
  /// 本地缓存 - 删除
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
  
  /// 本地缓存 - 清空
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
  
  /// 带过期时间的缓存
  Future<bool> setWithExpiry(String key, String value, Duration expiry) async {
    final data = {
      'value': value,
      'expiry': DateTime.now().add(expiry).millisecondsSinceEpoch,
    };
    return await setJson(key, data);
  }
  
  /// 读取带过期时间的缓存
  String? getWithExpiry(String key) {
    final data = getJson(key);
    if (data == null) return null;
    
    final expiry = data['expiry'] as int?;
    if (expiry == null) return null;
    
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      remove(key);
      return null;
    }
    
    return data['value'] as String?;
  }
}

/// API响应缓存控制器
class ApiCacheController {
  static const Duration _defaultCacheDuration = Duration(minutes: 5);
  final CacheService _cache = CacheService.to;
  
  /// 缓存API响应
  Future<void> cacheResponse(String endpoint, dynamic data, {Duration? duration}) async {
    final key = 'api_cache_$endpoint';
    await _cache.setWithExpiry(
      key, 
      jsonEncode(data), 
      duration ?? _defaultCacheDuration
    );
  }
  
  /// 获取缓存的API响应
  dynamic getCachedResponse(String endpoint) {
    final key = 'api_cache_$endpoint';
    final cached = _cache.getWithExpiry(key);
    if (cached == null) return null;
    try {
      return jsonDecode(cached);
    } catch (e) {
      return null;
    }
  }
  
  /// 清除缓存
  Future<void> clearCache(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('api_cache_'));
    for (final key in keys) {
      if (pattern.isEmpty || key.contains(pattern)) {
        await prefs.remove(key);
      }
    }
  }
}
