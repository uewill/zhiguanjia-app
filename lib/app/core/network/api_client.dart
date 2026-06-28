import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'api_exception.dart';
import 'api_interceptor.dart';

/// API 客户端
/// 统一处理 HTTP 请求、响应解析、错误处理
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // API 基础地址
  static const String baseUrl = 'http://localhost:8082/api';
  
  // 超时设置
  static const Duration timeout = Duration(seconds: 30);
  
  // 拦截器列表
  final List<ApiInterceptor> _interceptors = [];
  
  // Token 管理
  String? _token;
  
  void setToken(String? token) {
    _token = token;
  }
  
  void addInterceptor(ApiInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// GET 请求
  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _request<T>(
      method: 'GET',
      path: path,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// POST 请求
  Future<T> post<T>({
    required String path,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _request<T>(
      method: 'POST',
      path: path,
      body: body,
      headers: headers,
    );
  }

  /// PUT 请求
  Future<T> put<T>({
    required String path,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _request<T>(
      method: 'PUT',
      path: path,
      body: body,
      headers: headers,
    );
  }

  /// DELETE 请求
  Future<T> delete<T>({
    required String path,
    Map<String, String>? headers,
  }) async {
    return _request<T>(
      method: 'DELETE',
      path: path,
      headers: headers,
    );
  }

  /// 统一请求处理
  Future<T> _request<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryParams,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      // 构建 URL
      var uri = Uri.parse('$baseUrl$path');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // 构建请求头
      final requestHeaders = _buildHeaders(headers);

      // 执行拦截器 - 请求前
      var request = ApiRequest(
        method: method,
        url: uri,
        headers: requestHeaders,
        body: body,
      );
      for (var interceptor in _interceptors) {
        request = await interceptor.onRequest(request);
      }

      // 发送请求
      late final http.Response response;
      final encodedBody = body != null ? jsonEncode(body) : null;
      
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders).timeout(timeout);
        case 'POST':
          response = await http.post(uri, headers: requestHeaders, body: encodedBody).timeout(timeout);
        case 'PUT':
          response = await http.put(uri, headers: requestHeaders, body: encodedBody).timeout(timeout);
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders).timeout(timeout);
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      // 执行拦截器 - 响应后
      var apiResponse = ApiResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
      );
      for (var interceptor in _interceptors.reversed) {
        apiResponse = await interceptor.onResponse(apiResponse);
      }

      // 处理响应
      return _handleResponse<T>(apiResponse);

    } on SocketException catch (e) {
      throw ApiException('网络连接失败，请检查网络设置', code: 'NETWORK_ERROR');
    } on FormatException catch (e) {
      throw ApiException('数据格式错误', code: 'FORMAT_ERROR');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('请求失败: $e', code: 'UNKNOWN_ERROR');
    }
  }

  /// 构建请求头
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }

  /// 处理响应
  T _handleResponse<T>(ApiResponse response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      // 成功响应
      if (body.isEmpty) {
        return null as T;
      }

      final decoded = jsonDecode(body);
      
      // 处理标准响应格式 { "code": 200, "data": ..., "message": ... }
      if (decoded is Map && decoded.containsKey('code')) {
        final code = decoded['code'];
        if (code == 200 || code == 0) {
          final data = decoded['data'];
          return _convertData<T>(data);
        } else {
          throw ApiException(
            decoded['message'] ?? '请求失败',
            code: code.toString(),
          );
        }
      }
      
      return _convertData<T>(decoded);
    } else if (statusCode == 401) {
      throw ApiException('登录已过期，请重新登录', code: 'UNAUTHORIZED');
    } else if (statusCode == 403) {
      throw ApiException('没有权限执行此操作', code: 'FORBIDDEN');
    } else if (statusCode == 404) {
      throw ApiException('资源不存在', code: 'NOT_FOUND');
    } else if (statusCode >= 500) {
      throw ApiException('服务器内部错误', code: 'SERVER_ERROR');
    } else {
      throw ApiException('请求失败：$statusCode', code: 'HTTP_ERROR');
    }
  }

  /// 转换数据类型
  T _convertData<T>(dynamic data) {
    if (data == null) {
      return null as T;
    }
    
    if (T == dynamic) {
      return data as T;
    }
    
    if (T == String) {
      return data.toString() as T;
    }
    
    if (T == int) {
      return (data is int ? data : int.parse(data.toString())) as T;
    }
    
    if (T == double) {
      return (data is double ? data : double.parse(data.toString())) as T;
    }
    
    if (T == bool) {
      return (data is bool ? data : data.toString().toLowerCase() == 'true') as T;
    }
    
    return data as T;
  }
}

/// API 请求
class ApiRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final dynamic body;

  ApiRequest({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
  });
}

/// API 响应
class ApiResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  ApiResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });
}
