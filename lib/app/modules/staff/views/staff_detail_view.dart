import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/staff_controller.dart';
import '../../../data/models/staff_model.dart';

/// 职员详情页面
class StaffDetailView extends GetView<StaffController> {
  const StaffDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final staff = Get.arguments as Staff;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '职员详情',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
        rightBarItems: [
          TDNavBarItem(
            icon: TDIcons.edit,
            iconColor: Colors.white,
            action: () => controller.goToEdit(staff),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(staff),
          const SizedBox(height: 16),
          _buildInfoCard(staff),
          const SizedBox(height: 16),
          _buildRoleCard(staff),
          const SizedBox(height: 16),
          _buildTimeCard(staff),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Staff staff) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF2FC27D).withValues(alpha: 0.1),
            child: Text(
              staff.name.substring(0, 1),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2FC27D),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            staff.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(staff.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              staff.statusName,
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(staff.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Staff staff) {
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
              Icon(Icons.contact_phone, color: Color(0xFF2FC27D)),
              SizedBox(width: 8),
              Text(
                '联系信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, '手机号', staff.phone),
          if (staff.email != null && staff.email!.isNotEmpty)
            _buildInfoRow(Icons.email, '邮箱', staff.email!),
          _buildInfoRow(Icons.business, '部门', staff.departmentName),
          _buildInfoRow(Icons.work, '职位', staff.position),
        ],
      ),
    );
  }

  Widget _buildRoleCard(Staff staff) {
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: staff.roleIds.map((roleId) {
              final roleName = PredefinedRoles.names[roleId] ?? roleId;
              return Chip(
                label: Text(roleName),
                backgroundColor: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: Color(0xFF2FC27D),
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(Staff staff) {
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
              Icon(Icons.access_time, color: Color(0xFF2FC27D)),
              SizedBox(width: 8),
              Text(
                '时间信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (staff.entryDate != null)
            _buildInfoRow(Icons.login, '入职时间', _formatDate(staff.entryDate!)),
          _buildInfoRow(Icons.person_add, '创建时间', _formatDate(staff.createTime)),
          _buildInfoRow(Icons.update, '更新时间', _formatDate(staff.updateTime)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return const Color(0xFF2FC27D);
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
