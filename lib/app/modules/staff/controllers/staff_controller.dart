import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/staff_model.dart';
import '../../../services/staff_service.dart';

class StaffController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();

  // 职员列表
  final staffList = <Staff>[].obs;
  final filteredStaffList = <Staff>[].obs;
  final isLoading = false.obs;

  // 部门列表
  final departmentList = <Department>[].obs;
  final selectedDepartment = ''.obs;

  // 搜索
  final searchController = TextEditingController();

  // 表单
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final positionController = TextEditingController();
  final selectedRoleIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStaffList();
    loadDepartments();
  }

  Future<void> loadStaffList() async {
    isLoading.value = true;
    try {
      staffList.value = await _staffService.getStaffList();
      _filterStaff();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDepartments() async {
    departmentList.value = await _staffService.getDepartments();
  }

  void onDepartmentChanged(String? value) {
    selectedDepartment.value = value ?? '';
    _filterStaff();
  }

  void search(String keyword) {
    _filterStaff();
  }

  void _filterStaff() {
    var result = staffList;

    // 部门筛选
    if (selectedDepartment.isNotEmpty) {
      result = result.where((s) => s.departmentId == selectedDepartment.value).toList().obs;
    }

    // 搜索筛选
    if (searchController.text.isNotEmpty) {
      final keyword = searchController.text.toLowerCase();
      result = result.where((s) =>
        s.name.toLowerCase().contains(keyword) ||
        s.phone.contains(keyword)
      ).toList().obs;
    }

    filteredStaffList.value = result;
  }

  void goToCreate() {
    _clearForm();
    Get.toNamed('/staff/create');
  }

  void goToEdit(Staff staff) {
    _fillForm(staff);
    Get.toNamed('/staff/edit', arguments: staff);
  }

  void viewDetail(Staff staff) {
    Get.toNamed('/staff/detail', arguments: staff);
  }

  Future<void> saveStaff({String? staffId}) async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      _showToast('请填写姓名和手机号');
      return;
    }

    final staff = Staff(
      id: staffId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text,
      phone: phoneController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      departmentId: selectedDepartment.value.isEmpty ? '1' : selectedDepartment.value,
      departmentName: selectedDepartment.value.isEmpty ? '销售部' : _getDepartmentName(selectedDepartment.value),
      position: positionController.text.isEmpty ? '员工' : positionController.text,
      roleIds: selectedRoleIds.toList(),
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
    );

    final success = staffId != null
        ? await _staffService.updateStaff(staffId, staff)
        : await _staffService.createStaff(staff);

    if (success) {
      _showToast(staffId != null ? '更新成功' : '创建成功');
      loadStaffList();
      Get.back();
    } else {
      _showToast('操作失败');
    }
  }

  Future<void> deleteStaff(String staffId) async {
    // Show confirmation dialog using GetX dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，是否继续？'),
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
      final success = await _staffService.deleteStaff(staffId);
      if (success) {
        _showToast('删除成功');
        loadStaffList();
      } else {
        _showToast('删除失败');
      }
    }
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    positionController.clear();
    selectedRoleIds.clear();
    selectedDepartment.value = '';
  }

  void _fillForm(Staff staff) {
    nameController.text = staff.name;
    phoneController.text = staff.phone;
    emailController.text = staff.email ?? '';
    positionController.text = staff.position;
    selectedRoleIds.value = staff.roleIds;
    selectedDepartment.value = staff.departmentId;
  }

  String _getDepartmentName(String id) {
    final dept = departmentList.firstWhereOrNull((d) => d.id == id);
    return dept?.name ?? '未知';
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    positionController.dispose();
    super.onClose();
  }
}
