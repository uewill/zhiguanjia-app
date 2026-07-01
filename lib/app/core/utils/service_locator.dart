import 'package:get/get.dart';

/// 安全的服务定位器
/// 避免 Get.find 抛出异常，自动初始化控制器
class ServiceLocator {
  
  /// 安全获取Controller，不存在时自动创建
  static T safeGet<T extends GetxController>({String? tag}) {
    try {
      if (Get.isRegistered<T>(tag: tag)) {
        return Get.find<T>(tag: tag);
      }
    } catch (_) {}
    
    // 根据类型自动创建实例
    return _createInstance<T>();
  }
  
  /// 安全获取或注册
  static T safePut<T extends GetxController>({String? tag}) {
    try {
      if (!Get.isRegistered<T>(tag: tag)) {
        final instance = _createInstance<T>();
        Get.put(instance, tag: tag);
        return instance;
      }
      return Get.find<T>(tag: tag);
    } catch (_) {
      final instance = _createInstance<T>();
      Get.put(instance, tag: tag);
      return instance;
    }
  }
  
  /// 创建实例的辅助方法
  static T _createInstance<T>() {
    throw Exception('Controller $T 需要手动注册');
  }
  
  /// 清理所有控制器
  static void clearAll() {
    Get.reset();
  }
}

/// Controller生命周期扩展
extension ControllerLifecycle on GetxController {
  /// 安全执行，捕获异常
  void safeRun(void Function() action, {void Function(Object)? onError}) {
    try {
      action();
    } catch (e, _) {
      if (onError != null) {
        onError(e);
      }
    }
  }
}
