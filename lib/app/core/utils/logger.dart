import 'dart:developer' as developer;

/// 统一日志系统
class Logger {
  static const String _name = 'ZhiGuanJia';
  static bool _debugMode = true;
  
  /// 设置调试模式
  static void setDebugMode(bool debug) {
    _debugMode = debug;
  }
  
  /// 调试日志
  static void d(String message, {String? tag}) {
    if (_debugMode) {
      final log = _formatLog('D', tag, message);
      developer.log(log, name: _name);
    }
  }
  
  /// 信息日志
  static void i(String message, {String? tag}) {
    final log = _formatLog('I', tag, message);
    developer.log(log, name: _name);
  }
  
  /// 警告日志
  static void w(String message, {String? tag, Object? error}) {
    final log = _formatLog('W', tag, message);
    developer.log(log, name: _name, error: error);
  }
  
  /// 错误日志
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final log = _formatLog('E', tag, message);
    developer.log(log, name: _name, error: error, stackTrace: stackTrace);
  }
  
  /// 格式化日志
  static String _formatLog(String level, String? tag, String message) {
    final time = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag] ' : '';
    return '[$level] $time $tagStr$message';
  }
}

/// 日志扩展
extension LoggerExtension on Object {
  void logD(String message) {
    Logger.d(message, tag: runtimeType.toString());
  }
  
  void logI(String message) {
    Logger.i(message, tag: runtimeType.toString());
  }
  
  void logW(String message, {Object? error}) {
    Logger.w(message, tag: runtimeType.toString(), error: error);
  }
  
  void logE(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.e(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }
}
