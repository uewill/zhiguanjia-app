import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'cache_service.dart';

/// 缓存配置
class CacheConfig {
  final Duration duration;
  final bool forceRefresh;
  
  const CacheConfig({
    this.duration = const Duration(minutes: 5),
    this.forceRefresh = false,
  });
}

class ApiService extends getx.GetxService {
  late Dio _dio;
  late CacheService _cache;
  final Map<String, Completer<Response>> _pendingRequests = {};

  /// Get the underlying Dio instance
  Dio get dio => _dio;

  Future<ApiService> init() async {
    _cache = CacheService.to;
    onInit();
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: 'http://42.193.169.78:8083/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'X-Tenant-ID': '1',
        'Accept-Encoding': 'gzip',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加Token
        try {
          final token = getx.Get.find<getx.RxString>(tag: 'token');
          if (token.value.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.value}';
          }
        } catch (_) {}
        
        // 压缩请求数据
        if (options.data is Map && (options.data as Map).length > 1000) {
          options.headers['Content-Encoding'] = 'gzip';
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 解压响应数据
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized
        }
        return handler.next(error);
      },
    ));
    
    // 添加日志拦截器（仅debug模式）
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }
  }

  /// 带缓存的GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CacheConfig cacheConfig = const CacheConfig(),
  }) async {
    final cacheKey = '$path?${queryParameters.toString()}';
    
    // 尝试从缓存读取
    if (!cacheConfig.forceRefresh) {
      final cached = _cache.getMemory(cacheKey);
      if (cached != null) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: cached,
          statusCode: 200,
        );
      }
    }
    
    // 检查是否有进行中的同样请求
    if (_pendingRequests.containsKey(cacheKey)) {
      return await _pendingRequests[cacheKey]!.future;
    }
    
    // 创建新请求
    final completer = Completer<Response>();
    _pendingRequests[cacheKey] = completer;
    
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      
      // 缓存响应
      _cache.setMemory(cacheKey, response.data);
      
      completer.complete(response);
      return response;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    // 清除相关缓存
    _clearRelatedCache(path);
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    _clearRelatedCache(path);
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    _clearRelatedCache(path);
    return await _dio.delete(path);
  }
  
  /// 批量请求
  Future<List<Response>> batchGet(List<String> paths) async {
    final futures = paths.map((path) => get(path));
    return await Future.wait(futures);
  }
  
  /// 清除相关缓存
  void _clearRelatedCache(String path) {
    final keysToRemove = _cache.getMemoryKeys().where((key) => key.startsWith(path.split('/')[1]));
    for (final key in keysToRemove) {
      _cache.removeMemory(key);
    }
  }
}
