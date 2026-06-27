// 权限路由守卫
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../data/models/permission_model.dart';
import '../services/storage_service.dart';

class PermissionGuard {
  static final StorageService _storage = Get.find<StorageService>();

  // 验证页面访问权限
  static bool canAccessPage(String permissionCode) {
    final userPermissions = _storage.getUserPermissions();
    return PermissionUtils.hasPermission(userPermissions, permissionCode);
  }

  // 验证操作权限
  static bool canPerformAction(String actionCode) {
    final userPermissions = _storage.getUserPermissions();
    return PermissionUtils.hasPermission(userPermissions, actionCode);
  }

  // 路由中间件
  static GetPageRoute? onPageMiddleware(RouteSettings settings, BuildContext context) {
    final pagePermission = _getPagePermission(settings.name);
    if (pagePermission != null && !canAccessPage(pagePermission)) {
      // 无权限，显示提示并返回
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TDToast.showText('您没有权限访问该页面', context: context);
      });
      return null;
    }
    return null;
  }

  // 显示权限不足对话框
  static void showPermissionDenied(BuildContext context) {
    TDToast.showText('权限不足', context: context);
  }

  // 页面权限映射
  static String? _getPagePermission(String? routeName) {
    final permissionMap = {
      '/sale': 'sale',
      '/sale/create': 'sale:create',
      '/purchase': 'purchase',
      '/purchase/create': 'purchase:create',
      '/inventory': 'inventory',
      '/inventory/transfer': 'inventory:transfer',
      '/inventory/check': 'inventory:check',
      '/product': 'product',
      '/product/create': 'product:create',
      '/customer': 'customer',
      '/customer/create': 'customer:create',
      '/supplier': 'supplier',
      '/supplier/create': 'supplier:create',
      '/finance': 'finance',
      '/staff': 'staff',
      '/staff/create': 'staff:create',
      '/permission': 'staff:role',
    };
    return permissionMap[routeName];
  }
}

// 权限按钮组件
class PermissionButton extends StatelessWidget {
  final String permissionCode;
  final Widget child;
  final VoidCallback? onTap;

  const PermissionButton({
    Key? key,
    required this.permissionCode,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasPermission = PermissionGuard.canPerformAction(permissionCode);
    
    if (!hasPermission) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}
