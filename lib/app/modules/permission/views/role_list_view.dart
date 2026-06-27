import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/permission_controller.dart';

class RoleListView extends GetView<PermissionController> {
  const RoleListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('角色权限'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.goToCreateRole,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.roleList.length,
          itemBuilder: (context, index) {
            final role = controller.roleList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor(role.id),
                  child: Icon(_getRoleIcon(role.id), color: Colors.white),
                ),
                title: Text(role.name),
                subtitle: Text(role.description ?? '无描述'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'permission', child: Text('分配权限')),
                    const PopupMenuItem(value: 'staff', child: Text('分配职员')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                  onSelected: (value) {
                    if (value == 'permission') {
                      controller.goToAssignPermission(role);
                    } else if (value == 'staff') {
                      controller.goToAssignStaff(role);
                    } else if (value == 'delete') {
                      controller.deleteRole(role.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getRoleColor(String roleId) {
    final colors = {
      'admin': Colors.red,
      'owner': Colors.orange,
      'manager': Colors.blue,
      'salesperson': Colors.green,
      'purchaser': Colors.purple,
      'warehouse': Colors.brown,
      'accountant': Colors.teal,
      'cashier': Colors.indigo,
    };
    return colors[roleId] ?? Colors.grey;
  }

  IconData _getRoleIcon(String roleId) {
    final icons = {
      'admin': Icons.admin_panel_settings,
      'owner': Icons.business,
      'manager': Icons.manage_accounts,
      'salesperson': Icons.shopping_cart,
      'purchaser': Icons.shopping_bag,
      'warehouse': Icons.warehouse,
      'accountant': Icons.account_balance,
      'cashier': Icons.point_of_sale,
    };
    return icons[roleId] ?? Icons.person;
  }
}
