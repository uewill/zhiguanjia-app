import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/customer_controller.dart';

class CustomerListView extends GetView<CustomerController> {
  const CustomerListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildCustomerList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2FC27D),
        onPressed: () => _showAddCustomerDialog(),
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
              '客户管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
        hintText: '搜索客户名称/电话',
        backgroundColor: const Color(0xFFF2F3F5),
        leftIcon: const Icon(Icons.search, color: Colors.grey),
      ),
    );
  }

  Widget _buildCustomerList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.customers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const TDText('暂无客户', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TDButton(
                text: '添加客户',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.small,
                onTap: () => _showAddCustomerDialog(),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.customers.length,
        itemBuilder: (context, index) {
          final customer = controller.customers[index];
          return _buildCustomerCard(customer);
        },
      );
    });
  }

  Widget _buildCustomerCard(dynamic customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TDText(
                customer.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2129),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditCustomerDialog(customer),
                    child: const Icon(Icons.edit, size: 20, color: Color(0xFF2FC27D)),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showDeleteConfirm(customer),
                    child: const Icon(Icons.delete, size: 20, color: Color(0xFFF53F3F)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Color(0xFF86909C)),
              const SizedBox(width: 8),
              TDText(customer.phone, style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
            ],
          ),
          if (customer.address != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF86909C)),
                const SizedBox(width: 8),
                Expanded(
                  child: TDText(
                    customer.address,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: customer.balance >= 0
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TDText(
              '${customer.balance >= 0 ? '应收' : '应付'}: ¥${customer.balance.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: customer.balance >= 0 ? const Color(0xFF00B42A) : const Color(0xFFF53F3F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    controller.nameController.clear();
    controller.phoneController.clear();
    controller.addressController.clear();
    
    Get.dialog(
      AlertDialog(
        title: const Text('添加客户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TDInput(
                controller: controller.nameController,
                leftLabel: '客户名称',
                hintText: '请输入客户名称',
              ),
              const SizedBox(height: 12),
              TDInput(
                controller: controller.phoneController,
                leftLabel: '联系电话',
                hintText: '请输入联系电话',
              ),
              const SizedBox(height: 12),
              TDInput(
                controller: controller.addressController,
                leftLabel: '地址',
                hintText: '请输入地址（选填）',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TDButton(
            text: '保存',
            theme: TDButtonTheme.primary,
            onTap: () {
              if (controller.nameController.text.isEmpty) {
                TDToast.showText('请输入客户名称', context: Get.context!);
                return;
              }
              controller.createCustomer({
                'name': controller.nameController.text,
                'phone': controller.phoneController.text,
                'address': controller.addressController.text,
              });
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(dynamic customer) {
    controller.nameController.text = customer.name;
    controller.phoneController.text = customer.phone;
    controller.addressController.text = customer.address ?? '';
    
    Get.dialog(
      AlertDialog(
        title: const Text('编辑客户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TDInput(
                controller: controller.nameController,
                leftLabel: '客户名称',
                hintText: '请输入客户名称',
              ),
              const SizedBox(height: 12),
              TDInput(
                controller: controller.phoneController,
                leftLabel: '联系电话',
                hintText: '请输入联系电话',
              ),
              const SizedBox(height: 12),
              TDInput(
                controller: controller.addressController,
                leftLabel: '地址',
                hintText: '请输入地址（选填）',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TDButton(
            text: '保存',
            theme: TDButtonTheme.primary,
            onTap: () {
              controller.createCustomer({
                'id': customer.id,
                'name': controller.nameController.text,
                'phone': controller.phoneController.text,
                'address': controller.addressController.text,
              });
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(dynamic customer) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除客户 "${customer.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TDButton(
            text: '删除',
            theme: TDButtonTheme.danger,
            onTap: () {
              // TODO: 调用删除API
              Get.back();
              TDToast.showText('删除成功', context: Get.context!);
            },
          ),
        ],
      ),
    );
  }
}
