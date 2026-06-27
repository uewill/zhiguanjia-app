import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/supplier_controller.dart';

class SupplierListView extends GetView<SupplierController> {
  const SupplierListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildSupplierList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2FC27D),
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF2FC27D)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Expanded(
            child: TDText(
              '供应商管理',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: TDInput(
        controller: TextEditingController(),
        hintText: '搜索供应商名称/联系人',
        backgroundColor: const Color(0xFFF2F3F5),
        leftIcon: const Icon(Icons.search, color: Colors.grey),
      ),
    );
  }

  Widget _buildSupplierList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.suppliers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const TDText('暂无供应商', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TDButton(
                text: '添加供应商',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.small,
                onTap: () => _showAddDialog(),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.suppliers.length,
        itemBuilder: (context, index) {
          final supplier = controller.suppliers[index];
          return _buildSupplierCard(supplier);
        },
      );
    });
  }

  Widget _buildSupplierCard(dynamic supplier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TDText(
                supplier.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2129)),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditDialog(supplier),
                    child: const Icon(Icons.edit, size: 20, color: Color(0xFF2FC27D)),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showDeleteConfirm(supplier),
                    child: const Icon(Icons.delete, size: 20, color: Color(0xFFF53F3F)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (supplier.contact != null)
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Color(0xFF86909C)),
                const SizedBox(width: 8),
                TDText(supplier.contact, style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
              ],
            ),
          if (supplier.phone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFF86909C)),
                const SizedBox(width: 8),
                TDText(supplier.phone, style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAddDialog() {
    controller.nameController.clear();
    controller.contactController.clear();
    controller.phoneController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('添加供应商'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TDInput(controller: controller.nameController, leftLabel: '供应商名称', hintText: '请输入供应商名称'),
              const SizedBox(height: 12),
              TDInput(controller: controller.contactController, leftLabel: '联系人', hintText: '请输入联系人'),
              const SizedBox(height: 12),
              TDInput(controller: controller.phoneController, leftLabel: '联系电话', hintText: '请输入联系电话'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TDButton(
            text: '保存',
            theme: TDButtonTheme.primary,
            onTap: () {
              if (controller.nameController.text.isEmpty) {
                TDToast.showText('请输入供应商名称', context: Get.context!);
                return;
              }
              controller.createSupplier({
                'name': controller.nameController.text,
                'contact': controller.contactController.text,
                'phone': controller.phoneController.text,
              });
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(dynamic supplier) {
    controller.nameController.text = supplier.name;
    controller.contactController.text = supplier.contact;
    controller.phoneController.text = supplier.phone;
    
    Get.dialog(
      AlertDialog(
        title: const Text('编辑供应商'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TDInput(controller: controller.nameController, leftLabel: '供应商名称', hintText: '请输入供应商名称'),
              const SizedBox(height: 12),
              TDInput(controller: controller.contactController, leftLabel: '联系人', hintText: '请输入联系人'),
              const SizedBox(height: 12),
              TDInput(controller: controller.phoneController, leftLabel: '联系电话', hintText: '请输入联系电话'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TDButton(
            text: '保存',
            theme: TDButtonTheme.primary,
            onTap: () {
              controller.createSupplier({
                'id': supplier.id,
                'name': controller.nameController.text,
                'contact': controller.contactController.text,
                'phone': controller.phoneController.text,
              });
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(dynamic supplier) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除供应商 "${supplier.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TDButton(
            text: '删除',
            theme: TDButtonTheme.danger,
            onTap: () {
              Get.back();
              TDToast.showText('删除成功', context: Get.context!);
            },
          ),
        ],
      ),
    );
  }
}
