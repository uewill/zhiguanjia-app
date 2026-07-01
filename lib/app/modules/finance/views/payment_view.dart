import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class PaymentController extends GetxController {
  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  final selectedCustomer = Rxn<Map<String, dynamic>>();
  final paymentType = 'receive'.obs; // 'receive' or 'pay'

  final customers = [
    {'id': 1, 'name': '张三客户', 'balance': 1250.0},
    {'id': 2, 'name': '李四客户', 'balance': -500.0},
    {'id': 3, 'name': '可口可乐供应商', 'balance': 0.0},
  ];

  Future<void> submitPayment() async {
    if (selectedCustomer.value == null) {
      TDToast.showText('请选择${paymentType.value == 'receive' ? '付款人' : '收款人'}', context: Get.context!);
      return;
    }
    if (amountController.text.isEmpty) {
      TDToast.showText('请输入金额', context: Get.context!);
      return;
    }

    TDToast.showText('收付款记录已保存', context: Get.context!);
    Get.back();
  }
}

class PaymentView extends GetView<PaymentController> {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PaymentController());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTypeSelector(),
                  _buildCustomerSelector(),
                  _buildAmountInput(),
                  _buildRemarkInput(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF2FC27D)),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const Expanded(
              child: TDText('收付款', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('收付类型', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.paymentType.value = 'receive',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.paymentType.value == 'receive' ? const Color(0xFF2FC27D) : const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TDText('收款', style: TextStyle(
                        color: controller.paymentType.value == 'receive' ? Colors.white : const Color(0xFF4E5969),
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.paymentType.value = 'pay',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.paymentType.value == 'pay' ? const Color(0xFFF53F3F) : const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TDText('付款', style: TextStyle(
                        color: controller.paymentType.value == 'pay' ? Colors.white : const Color(0xFF4E5969),
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => TDText(
            controller.paymentType.value == 'receive' ? '选择客户' : '选择供应商',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )),
          const SizedBox(height: 12),
          Obx(() => GestureDetector(
            onTap: () => _showCustomerPicker(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E6EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.paymentType.value == 'receive' ? Icons.person : Icons.business,
                    color: const Color(0xFF86909C),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TDText(
                      controller.selectedCustomer.value?['name'] ?? '请选择${controller.paymentType.value == 'receive' ? '客户' : '供应商'}',
                      style: TextStyle(
                        color: controller.selectedCustomer.value != null
                            ? const Color(0xFF1D2129)
                            : const Color(0xFF86909C),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF86909C)),
                ],
              ),
            ),
          )),
          Obx(() {
            if (controller.selectedCustomer.value == null) return const SizedBox.shrink();
            final balance = controller.selectedCustomer.value!['balance'] as double;
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: balance >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TDText(balance >= 0 ? '应收余额' : '应付余额', style: TextStyle(
                    color: balance >= 0 ? const Color(0xFF00B42A) : const Color(0xFFF53F3F),
                  )),
                  TDText('¥${balance.abs().toStringAsFixed(2)}', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? const Color(0xFF00B42A) : const Color(0xFFF53F3F),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('金额', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TDInput(
            controller: controller.amountController,
            hintText: '请输入金额',
            leftLabel: '¥',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [100, 200, 500, 1000].map((amount) => GestureDetector(
              onTap: () => controller.amountController.text = amount.toString(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E6EB)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TDText('¥$amount', style: const TextStyle(fontSize: 12)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TDInput(
        controller: controller.remarkController,
        leftLabel: '备注',
        hintText: '请输入备注（选填）',
        maxLines: 3,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: SafeArea(
        top: false,
        child: TDButton(
          text: '确认保存',
          theme: TDButtonTheme.primary,
          size: TDButtonSize.large,
          isBlock: true,
          onTap: () => controller.submitPayment(),
        ),
      ),
    );
  }

  void _showCustomerPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => TDText(
                    controller.paymentType.value == 'receive' ? '选择客户' : '选择供应商',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: controller.customers.length,
              itemBuilder: (context, index) {
                final customer = controller.customers[index];
                return ListTile(
                  title: TDText(customer['name']),
                  trailing: TDText('¥${(customer['balance'] as double).toStringAsFixed(2)}', style: TextStyle(
                    color: (customer['balance'] as double) >= 0 ? const Color(0xFF00B42A) : const Color(0xFFF53F3F),
                  )),
                  onTap: () {
                    controller.selectedCustomer.value = customer;
                    Get.back();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
