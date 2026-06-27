import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/permission_model.dart';
import '../../../data/models/staff_model.dart';
import '../controllers/permission_controller.dart';

class PermissionAssignView extends GetView<PermissionController> {
  const PermissionAssignView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role = Get.arguments as Role;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('分配权限 - ${role.name}'),
        actions: [
          TextButton(
            onPressed: () => controller.updateRolePermissions(role.id),
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: _getGroupedPermissions().length,
          itemBuilder: (context, index) {
            final group = _getGroupedPermissions()[index];
            return _buildPermissionGroup(group);
          },
        );
      }),
    );
  }

  List<Map<String, dynamic>> _getGroupedPermissions() {
    final groups = <String, List<Permission>>{};
    
    for (final perm in controller.allPermissions) {
      if (perm.type == 1) {
        groups[perm.code] = [perm];
      }
    }
    
    for (final perm in controller.allPermissions) {
      if (perm.type != 1 && perm.parentCode != null) {
        groups[perm.parentCode]?.add(perm);
      }
    }
    
    return groups.entries.map((e) => {
      'module': e.value.first,
      'children': e.value.skip(1).toList(),
    }).toList();
  }

  Widget _buildPermissionGroup(Map<String, dynamic> group) {
    final module = group['module'] as Permission;
    final children = group['children'] as List<Permission>;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模块标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                Obx(() => Checkbox(
                  value: _isModuleChecked(module.code, children),
                  onChanged: (checked) => _toggleModule(module.code, children, checked),
                )),
                const SizedBox(width: 8),
                Text(
                  module.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 子权限列表
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: children.map((child) => Obx(() => FilterChip(
                  label: Text(child.name),
                  selected: controller.selectedPermissions.contains(child.code),
                  onSelected: (_) => controller.togglePermission(child.code),
                ))).toList(),
              ),
            ),
        ],
      ),
    );
  }

  bool _isModuleChecked(String moduleCode, List<Permission> children) {
    if (controller.selectedPermissions.contains(moduleCode)) {
      return true;
    }
    // 检查是否所有子权限都选中
    if (children.isNotEmpty) {
      return children.every((c) => controller.selectedPermissions.contains(c.code));
    }
    return false;
  }

  void _toggleModule(String moduleCode, List<Permission> children, bool? checked) {
    if (checked == true) {
      controller.selectedPermissions.add(moduleCode);
      for (final child in children) {
        controller.selectedPermissions.add(child.code);
      }
    } else {
      controller.selectedPermissions.remove(moduleCode);
      for (final child in children) {
        controller.selectedPermissions.remove(child.code);
      }
    }
  }
}
