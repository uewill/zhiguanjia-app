import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/product_model.dart';

class StockCheckController extends GetxController {
  final checkItems = <CheckItem>[].obs;
  final remark = TextEditingController();

  int get totalDiff => checkItems.fold(0, (sum, item) => sum + (item.actualQty - item.systemQty));

  void addItem(Product product) {
    checkItems.add(CheckItem(
      product: product,
      systemQty: product.stock,
      actualQty: product.stock,
    ));
  }

  void updateActualQty(int index, int qty) {
    checkItems[index].actualQty = qty;
    checkItems.refresh();
  }

  void removeItem(int index) {
    checkItems.removeAt(index);
  }

  Future<void> submitCheck() async {
    if (checkItems.isEmpty) {
      TDToast.showText('请添加盘点商品', context: Get.context!);
      return;
    }

    TDToast.showText('盘点单提交成功', context: Get.context!);
    Get.back();
  }
}

class CheckItem {
  final Product product;
  final int systemQty;
  int actualQty;

  CheckItem({required this.product, required this.systemQty, required this.actualQty});
  int get diff => actualQty - systemQty;
}

class StockCheckView extends GetView<StockCheckController> {
  const StockCheckView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(StockCheckController());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductSelector(),
                  _buildCheckList(),
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
              child: TDText('库存盘点', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TDText('盘点商品', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildCheckList() {
    return Obx(() {
      if (controller.checkItems.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                const TDText('请添加盘点商品', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E6EB))),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: TDText('商品', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: TDText('库存', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: TDText('实盘', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: TDText('盘差', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.checkItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildCheckItem(index),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCheckItem(int index) {
    final item = controller.checkItems[index];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(flex: 2, child: TDText(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(child: TDText('${item.systemQty}', textAlign: TextAlign.center)),
          Expanded(
            child: GestureDetector(
              onTap: () => _showQtyInput(index, item.actualQty),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2FC27D)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TDText('${item.actualQty}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF2FC27D))),
              ),
            ),
          ),
          Expanded(
            child: TDText(
              '${item.diff > 0 ? '+' : ''}${item.diff}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: item.diff == 0 ? const Color(0xFF86909C) : (item.diff > 0 ? const Color(0xFF00B42A) : const Color(0xFFF53F3F)),
                fontWeight: FontWeight.bold,
              ),
            ),
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
        leftLabel: '盘点备注',
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
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TDText('共 ${controller.checkItems.length} 种商品', style: const TextStyle(color: Color(0xFF86909C))),
                  TDText('总盘差: ${controller.totalDiff > 0 ? '+' : ''}${controller.totalDiff}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )),
            ),
            TDButton(
              text: '提交盘点单',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: () => controller.submitCheck(),
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
                    controller.addItem(product);
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

  void _showQtyInput(int index, int currentQty) {
    final controller = TextEditingController(text: '$currentQty');
    Get.dialog(
      AlertDialog(
        title: const Text('输入实际数量'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TDButton(
            text: '确定',
            theme: TDButtonTheme.primary,
            onTap: () {
              final qty = int.tryParse(controller.text) ?? currentQty;
              this.controller.updateActualQty(index, qty);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
