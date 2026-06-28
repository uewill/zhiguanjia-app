import 'api_client.dart';

/// API 拦截器接口
abstract class ApiInterceptor {
  /// 请求前处理
  Future<ApiRequest> onRequest(ApiRequest request) async => request;
  
  /// 响应后处理
  Future<ApiResponse> onResponse(ApiResponse response) async => response;
  
  /// 错误处理
  Future<void> onError(ApiException error) async {}
}

/// 日志拦截器
class LoggingInterceptor implements ApiInterceptor {
  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    print('┌─────────────────────────────────────────');
    print('│ REQUEST: ${request.method} ${request.url}');
    print('│ HEADERS: ${request.headers}');
    if (request.body != null) {
      print('│ BODY: ${request.body}');
    }
    print('└─────────────────────────────────────────');
    return request;
  }

  @override
  Future<ApiResponse> onResponse(ApiResponse response) async {
    print('┌─────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode}');
    print('│ BODY: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
    print('└─────────────────────────────────────────');
    return response;
  }

  @override
  Future<void> onError(ApiException error) async {
    print('┌─────────────────────────────────────────');
    print('│ ERROR: ${error.code} - ${error.message}');
    print('└─────────────────────────────────────────');
  }
}

/// Token 拦截器
class TokenInterceptor implements ApiInterceptor {
  final Future<String?> Function() tokenGetter;
  final Function()? onTokenExpired;

  TokenInterceptor({required this.tokenGetter, this.onTokenExpired});

  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    final token = await tokenGetter();
    if (token != null) {
      final headers = Map<String, String>.from(request.headers);
      headers['Authorization'] = 'Bearer $token';
      return ApiRequest(
        method: request.method,
        url: request.url,
        headers: headers,
        body: request.body,
      );
    }
    return request;
  }

  @override
  Future<ApiResponse> onResponse(ApiResponse response) async {
    if (response.statusCode == 401) {
      onTokenExpired?.call();
    }
    return response;
  }

  @override
  Future<void> onError(ApiException error) async {}
}
