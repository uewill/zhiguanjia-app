import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/product_model.dart';

class InventoryTransferController extends GetxController {
  final sourceWarehouse = '主仓库'.obs;
  final targetWarehouse = '分仓库'.obs;
  final remark = TextEditingController();
  final transferItems = <TransferItem>[].obs;

  final warehouses = ['主仓库', '分仓库', '临时仓库'];

  double get totalAmount => transferItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get totalQuantity => transferItems.fold(0, (sum, item) => sum + item.quantity);

  void addItem(Product product, int quantity, double price) {
    transferItems.add(TransferItem(product: product, quantity: quantity, price: price));
  }

  void removeItem(int index) {
    transferItems.removeAt(index);
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      transferItems[index].quantity = quantity;
      transferItems.refresh();
    }
  }

  Future<void> submitTransfer() async {
    if (sourceWarehouse.value == targetWarehouse.value) {
      TDToast.showText('调出仓库和调入仓库不能相同', context: Get.context!);
      return;
    }
    if (transferItems.isEmpty) {
      TDToast.showText('请添加调拨商品', context: Get.context!);
      return;
    }

    TDToast.showText('调拨单提交成功', context: Get.context!);
    Get.back();
  }
}

class TransferItem {
  final Product product;
  int quantity;
  final double price;

  TransferItem({required this.product, required this.quantity, required this.price});
}

class InventoryTransferView extends GetView<InventoryTransferController> {
  const InventoryTransferView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(InventoryTransferController());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildWarehouseSelector(),
                  _buildProductSelector(),
                  _buildTransferList(),
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
              child: TDText('库存调拨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseSelector() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('调拨信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Obx(() => _buildWarehouseDropdown('调出仓库', controller.sourceWarehouse.value, (v) => controller.sourceWarehouse.value = v)),
          const SizedBox(height: 12),
          const Center(child: Icon(Icons.arrow_downward, color: Color(0xFF2FC27D))),
          const SizedBox(height: 12),
          Obx(() => _buildWarehouseDropdown('调入仓库', controller.targetWarehouse.value, (v) => controller.targetWarehouse.value = v)),
        ],
      ),
    );
  }

  Widget _buildWarehouseDropdown(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TDText(label, style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E6EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: controller.warehouses.map((w) => DropdownMenuItem(value: w, child: TDText(w))).toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TDText('调拨商品', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          TDButton(
            text: '添加商品',
            theme: TDButtonTheme.primary,
            size: TDButtonSize.small,
            onTap: () => _showProductPicker(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferList() {
    return Obx(() {
      if (controller.transferItems.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.move_to_inbox_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                const TDText('请添加调拨商品', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transferItems.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) => _buildTransferItem(index),
        ),
      );
    });
  }

  Widget _buildTransferItem(int index) {
    final item = controller.transferItems[index];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF2F3F5), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image, color: Color(0xFF86909C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                TDText('库存: ${item.product.stock}', style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.updateQuantity(index, item.quantity - 1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E6EB)), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12), child: TDText('${item.quantity}')),
              GestureDetector(
                onTap: () => controller.updateQuantity(index, item.quantity + 1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF2FC27D), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkInput() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TDInput(
        controller: controller.remark,
        leftLabel: '备注',
        hintText: '请输入备注信息（选填）',
        maxLines: 3,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Obx(() => TDText('共 ${controller.totalQuantity} 件商品', style: const TextStyle(color: Color(0xFF86909C)))),
            ),
            TDButton(
              text: '提交调拨单',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: () => controller.submitTransfer(),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductPicker() {
    final products = [
      Product(id: 1, name: '可口可乐', code: 'C001', barcode: '123', category: '饮料', unit: '瓶', salePrice: 3.5, purchasePrice: 2.8, stock: 100, minStock: 10),
      Product(id: 2, name: '红牛', code: 'C002', barcode: '234', category: '饮料', unit: '罐', salePrice: 6.0, purchasePrice: 4.5, stock: 50, minStock: 5),
      Product(id: 3, name: '方便面', code: 'C003', barcode: '345', category: '食品', unit: '袋', salePrice: 4.5, purchasePrice: 3.2, stock: 80, minStock: 10),
    ];

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
                  const TDText('选择商品', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: TDText(product.name),
                  subtitle: TDText('库存: ${product.stock}', style: const TextStyle(color: Color(0xFF86909C))),
                  onTap: () {
                    controller.addItem(product, 1, product.purchasePrice);
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
