import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/permission_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../services/permission_service.dart';
import '../../../services/staff_service.dart';

class PermissionController extends GetxController {
  final PermissionService _permissionService = Get.find<PermissionService>();
  final StaffService _staffService = Get.find<StaffService>();

  // 角色列表
  final roleList = <Role>[].obs;
  final isLoading = false.obs;

  // 权限树
  final allPermissions = <Permission>[].obs;
  final selectedPermissions = <String>[].obs;

  // 表单
  final roleNameController = TextEditingController();
  final roleDescController = TextEditingController();

  // 职员分配
  final staffList = <Staff>[].obs;
  final selectedStaffIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRoles();
    loadPermissions();
  }

  Future<void> loadRoles() async {
    isLoading.value = true;
    try {
      roleList.value = await _permissionService.getRoles();
    } finally {
      isLoading.value = false;
    }
  }

  void loadPermissions() {
    allPermissions.value = Permission.allPermissions;
  }

  void goToCreateRole() {
    _clearForm();
    Get.toNamed('/permission/role/create');
  }

  void goToEditRole(Role role) {
    _fillForm(role);
    Get.toNamed('/permission/role/edit', arguments: role);
  }

  void goToAssignPermission(Role role) {
    selectedPermissions.value = role.permissions;
    Get.toNamed('/permission/assign', arguments: role);
  }

  Future<void> saveRole({String? roleId}) async {
    if (roleNameController.text.isEmpty) {
      _showToast('请填写角色名称');
      return;
    }

    final role = Role(
      id: roleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: roleNameController.text,
      description: roleDescController.text.isEmpty ? null : roleDescController.text,
      permissions: selectedPermissions.toList(),
      createTime: DateTime.now(),
    );

    final success = await _permissionService.createRole(role);
    if (success) {
      _showToast('创建成功');
      loadRoles();
      Get.back();
    } else {
      _showToast('操作失败');
    }
  }

  Future<void> updateRolePermissions(String roleId) async {
    final success = await _permissionService.updateRolePermissions(
      roleId,
      selectedPermissions.toList(),
    );
    if (success) {
      _showToast('权限更新成功');
      loadRoles();
      Get.back();
    } else {
      _showToast('更新失败');
    }
  }

  Future<void> deleteRole(String roleId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除角色后将影响分配了该角色的职员，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _permissionService.deleteRole(roleId);
      if (success) {
        _showToast('删除成功');
        loadRoles();
      } else {
        _showToast('删除失败');
      }
    }
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  // 分配角色给职员
  Future<void> goToAssignStaff(Role role) async {
    staffList.value = await _staffService.getStaffList();
    selectedStaffIds.value = staffList
        .where((s) => s.roleIds.contains(role.id))
        .map((s) => s.id)
        .toList();
    Get.toNamed('/permission/staff-assign', arguments: role);
  }

  Future<void> assignRoleToStaff(String roleId) async {
    for (final staffId in selectedStaffIds) {
      await _staffService.assignRoles(staffId, [roleId]);
    }
    _showToast('分配成功');
    Get.back();
  }

  void togglePermission(String permissionCode) {
    if (selectedPermissions.contains(permissionCode)) {
      selectedPermissions.remove(permissionCode);
    } else {
      selectedPermissions.add(permissionCode);
    }
  }

  void toggleStaff(String staffId) {
    if (selectedStaffIds.contains(staffId)) {
      selectedStaffIds.remove(staffId);
    } else {
      selectedStaffIds.add(staffId);
    }
  }

  void _clearForm() {
    roleNameController.clear();
    roleDescController.clear();
    selectedPermissions.clear();
  }

  void _fillForm(Role role) {
    roleNameController.text = role.name;
    roleDescController.text = role.description ?? '';
    selectedPermissions.value = role.permissions;
  }

  @override
  void onClose() {
    roleNameController.dispose();
    roleDescController.dispose();
    super.onClose();
  }
}
