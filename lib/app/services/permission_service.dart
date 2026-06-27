// 权限服务
import 'package:dio/dio.dart';
import '../data/models/permission_model.dart';
import '../data/models/staff_model.dart';
import 'api_service.dart';

class PermissionService {
  final ApiService _apiService;

  PermissionService(this._apiService);

  // 获取当前用户权限
  Future<List<String>> getCurrentUserPermissions() async {
    try {
      final response = await _apiService.dio.get('/auth/permissions');
      if (response.data['code'] == 200) {
        return List<String>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('获取权限失败: $e');
      return [];
    }
  }

  // 获取角色列表
  Future<List<Role>> getRoles() async {
    try {
      final response = await _apiService.dio.get('/roles');
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map((e) => Role.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取角色列表失败: $e');
      return _getDefaultRoles();
    }
  }

  // 创建角色
  Future<bool> createRole(Role role) async {
    try {
      final response = await _apiService.dio.post('/roles', data: role.toJson());
      return response.data['code'] == 200;
    } catch (e) {
      print('创建角色失败: $e');
      return false;
    }
  }

  // 更新角色权限
  Future<bool> updateRolePermissions(String roleId, List<String> permissions) async {
    try {
      final response = await _apiService.dio.put(
        '/roles/$roleId/permissions',
        data: {'permissions': permissions},
      );
      return response.data['code'] == 200;
    } catch (e) {
      print('更新角色权限失败: $e');
      return false;
    }
  }

  // 删除角色
  Future<bool> deleteRole(String roleId) async {
    try {
      final response = await _apiService.dio.delete('/roles/$roleId');
      return response.data['code'] == 200;
    } catch (e) {
      print('删除角色失败: $e');
      return false;
    }
  }

  // 获取默认角色
  List<Role> _getDefaultRoles() {
    return [
      Role(id: 'admin', name: '超级管理员', description: '拥有所有权限', permissions: ['*'], createTime: DateTime.now()),
      Role(id: 'owner', name: '老板', description: '店铺负责人', permissions: Permission.roleDefaultPermissions['owner'] ?? [], createTime: DateTime.now()),
      Role(id: 'manager', name: '经理', description: '日常管理', permissions: Permission.roleDefaultPermissions['manager'] ?? [], createTime: DateTime.now()),
      Role(id: 'salesperson', name: '销售员', description: '负责销售', permissions: Permission.roleDefaultPermissions['salesperson'] ?? [], createTime: DateTime.now()),
      Role(id: 'purchaser', name: '采购员', description: '负责采购', permissions: Permission.roleDefaultPermissions['purchaser'] ?? [], createTime: DateTime.now()),
      Role(id: 'warehouse', name: '库管', description: '负责库存', permissions: Permission.roleDefaultPermissions['warehouse'] ?? [], createTime: DateTime.now()),
      Role(id: 'accountant', name: '财务', description: '负责财务', permissions: Permission.roleDefaultPermissions['accountant'] ?? [], createTime: DateTime.now()),
      Role(id: 'cashier', name: '收银员', description: '负责收银', permissions: Permission.roleDefaultPermissions['cashier'] ?? [], createTime: DateTime.now()),
      Role(id: 'viewer', name: '仅查看', description: '只读权限', permissions: Permission.roleDefaultPermissions['viewer'] ?? [], createTime: DateTime.now()),
    ];
  }

  // 获取所有可用权限
  List<Permission> getAllPermissions() {
    return Permission.allPermissions;
  }
}
