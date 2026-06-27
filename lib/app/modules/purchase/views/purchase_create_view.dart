import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/purchase_controller.dart';
import '../../../widgets/supplier_selector.dart';
import '../../../widgets/product_selector.dart';

class PurchaseCreateView extends GetView<PurchaseController> {
  const PurchaseCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建采购'),
        backgroundColor: const Color(0xFF2fc27d),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: controller.isCreating.value ? null : controller.createPurchase,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSupplierSection(context),
                  const SizedBox(height: 16),
                  _buildItemsSection(context),
                  const SizedBox(height: 16),
                  _buildRemarkSection(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        );
      }),
    );
  }

  Widget _buildSupplierSection(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('选择供应商'),
        subtitle: controller.selectedSupplier.value != null
              ? Text(controller.selectedSupplier.value!['name'] as String)
            : const Text('请选择供应商', style: TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final supplier = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const SupplierSelector(),
          );
          if (supplier != null) {
            controller.selectSupplier(supplier);
          }
        },
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('采购明细'),
            trailing: TextButton(
              onPressed: () async {
                final item = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const ProductSelector(),
                );
                if (item != null) {
                  controller.addItem(item);
                }
              },
              child: const Text('添加商品'),
            ),
          ),
          const Divider(height: 1),
          ...controller.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ListTile(
              title: Text(item['productName'] as String),
            subtitle: Text('¥${(item['unitPrice'] as double).toStringAsFixed(2)} x ${item['quantity']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('¥${(item['amount'] as double).toStringAsFixed(2)}'),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.removeItem(index),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRemarkSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: controller.remarkController,
          decoration: const InputDecoration(
            labelText: '备注',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('采购总额', style: TextStyle(color: Colors.grey)),
                  Text(
                    '¥${controller.totalAmount.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2fc27d),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: controller.isCreating.value ? null : controller.createPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2fc27d),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: controller.isCreating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('确认入库'),
            ),
          ],
        ),
      ),
    );
  }
}
