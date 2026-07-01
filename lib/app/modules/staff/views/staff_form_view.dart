import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/staff_controller.dart';
import '../../../data/models/staff_model.dart';

/// 职员表单页面 - 新增/编辑
class StaffFormView extends GetView<StaffController> {
  const StaffFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final isEdit = args != null && args is Staff;
    final staff = isEdit ? args as Staff : null;

    // 如果是编辑模式，填充表单
    if (isEdit && staff != null) {
      controller.nameController.text = staff.name;
      controller.phoneController.text = staff.phone;
      controller.emailController.text = staff.email ?? '';
      controller.positionController.text = staff.position;
      controller.selectedRoleIds.value = staff.roleIds;
      controller.selectedDepartment.value = staff.departmentId;
    } else {
      // 新增模式，清空表单
      controller.nameController.clear();
      controller.phoneController.clear();
      controller.emailController.clear();
      controller.positionController.clear();
      controller.selectedRoleIds.clear();
      controller.selectedDepartment.value = '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: isEdit ? '编辑职员' : '新增职员',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 16),
                _buildDepartmentSection(),
                const SizedBox(height: 16),
                _buildRoleSection(),
              ],
            ),
          ),
          _buildBottomBar(isEdit, staff?.id),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF2FC27D)),
              SizedBox(width: 8),
              Text(
                '基本信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: controller.nameController,
            leftLabel: '姓名',
            hintText: '请输入姓名',
            required: true,
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: controller.phoneController,
            leftLabel: '手机号',
            hintText: '请输入手机号',
            required: true,
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: controller.emailController,
            leftLabel: '邮箱',
            hintText: '请输入邮箱（选填）',
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: controller.positionController,
            leftLabel: '职位',
            hintText: '请输入职位（如：销售员）',
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business, color: Color(0xFF2FC27D)),
              SizedBox(width: 8),
              Text(
                '所属部门',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.departmentList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.departmentList.map((dept) {
                final isSelected = controller.selectedDepartment.value == dept.id;
                return ChoiceChip(
                  label: Text(dept.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedDepartment.value = dept.id;
                    }
                  },
                  selectedColor: const Color(0xFF2FC27D),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoleSection() {
    final roles = PredefinedRoles.names.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: Color(0xFF2FC27D)),
              SizedBox(width: 8),
              Text(
                '角色权限',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '可多选，角色决定职员的操作权限',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: roles.map((entry) {
                final isSelected = controller.selectedRoleIds.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedRoleIds.add(entry.key);
                    } else {
                      controller.selectedRoleIds.remove(entry.key);
                    }
                  },
                  selectedColor: const Color(0xFF2FC27D).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF2FC27D),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isEdit, String? staffId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: TDButton(
          theme: TDButtonTheme.primary,
          size: TDButtonSize.large,
          isBlock: true,
          text: isEdit ? '保存修改' : '创建职员',
          onTap: () => controller.saveStaff(staffId: staffId),
        ),
      ),
    );
  }
}
