/// API 异常
class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  ApiException(this.message, {this.code, this.data});

  @override
  String toString() => 'ApiException{code: $code, message: $message}';
}

/// 业务异常
typedef BusinessException = ApiException;

/// 网络异常
class NetworkException extends ApiException {
  NetworkException([String? message]) : super(message ?? '网络连接失败', code: 'NETWORK_ERROR');
}

/// 超时异常
class TimeoutException extends ApiException {
  TimeoutException([String? message]) : super(message ?? '请求超时', code: 'TIMEOUT_ERROR');
}

/// 认证异常
class AuthException extends ApiException {
  AuthException([String? message]) : super(message ?? '认证失败', code: 'AUTH_ERROR');
}
