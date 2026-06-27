import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/staff_controller.dart';

class StaffListView extends GetView<StaffController> {
  const StaffListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('职员管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.goToCreate,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: TDInput(
              controller: controller.searchController,
              leftIcon: const Icon(Icons.search),
              hintText: '搜索姓名或手机号',
              onChanged: controller.search,
            ),
          ),
          // 部门筛选
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('全部', '', controller.selectedDepartment.value == ''),
                ...controller.departmentList.map((dept) => _buildFilterChip(
                  dept.name,
                  dept.id,
                  controller.selectedDepartment.value == dept.id,
                )),
              ],
            ),
          )),
          const SizedBox(height: 8),
          // 职员列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredStaffList.isEmpty) {
                return const Center(child: Text('暂无职员'));
              }
              return ListView.builder(
                itemCount: controller.filteredStaffList.length,
                itemBuilder: (context, index) {
                  final staff = controller.filteredStaffList[index];
                  return _buildStaffCard(staff);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => controller.onDepartmentChanged(value),
      ),
    );
  }

  Widget _buildStaffCard(staff) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(staff.name.substring(0, 1)),
        ),
        title: Text(staff.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${staff.departmentName} - ${staff.position}'),
            Text(staff.phone, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              controller.goToEdit(staff);
            } else if (value == 'delete') {
              controller.deleteStaff(staff.id);
            }
          },
        ),
        onTap: () => controller.viewDetail(staff),
      ),
    );
  }
}
