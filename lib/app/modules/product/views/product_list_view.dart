import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/product_controller.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '商品管理',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        rightBarItems: [
          TDNavBarItem(
            iconWidget: const TDText('+', style: TextStyle(color: Colors.white, fontSize: 24)),
            action: () => Get.toNamed('/products/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TDInput(
              type: TDInputType.normal,
              hintText: '搜索商品名称/编码',
              leftIcon: const TDText('🔍', style: TextStyle(fontSize: 20)),
              onChanged: (value) => controller.searchProducts(value),
              backgroundColor: const Color(0xFFF5F5F5),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.filteredProducts.isEmpty) {
                return const Center(
                  child: TDLoading(
                    size: TDLoadingSize.large,
                    icon: TDLoadingIcon.circle,
                  ),
                );
              }

              if (controller.filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TDText('📦', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      const TDText('暂无商品数据', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      TDButton(
                        text: '添加商品',
                        theme: TDButtonTheme.primary,
                        onTap: () => Get.toNamed('/products/create'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  return _buildProductCard(product);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Get.toNamed('/products/create'),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF2FC27D),
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: const Center(
            child: TDText('+', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final isLowStock = product.stock <= product.minStock;
    final hasMultiUnit = product.units != null && product.units!.isNotEmpty;
    final hasMultiSku = product.hasSku == true;
    final hasBarcode = product.barcode != null && product.barcode!.isNotEmpty;

    return GestureDetector(
      onTap: () => Get.toNamed('/product/detail', arguments: product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLowStock ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: TDText(isLowStock ? '⚠️' : '📦', style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TDText(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      if (hasMultiSku)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const TDText('多规格', style: TextStyle(fontSize: 10, color: Color(0xFF1976D2))),
                        ),
                      if (hasMultiUnit)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const TDText('多单位', style: TextStyle(fontSize: 10, color: Color(0xFF7B1FA2))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TDText('编码: ${product.code}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (hasBarcode) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.qr_code, size: 12, color: Colors.grey),
                        TDText(' ${product.barcode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ],
                  ),
                  if (product.category != null) ...[
                    const SizedBox(height: 2),
                    TDText('分类: ${product.category}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TDText('¥${product.salePrice}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2FC27D))),
                const SizedBox(height: 4),
                TDText('库存: ${product.stock}${product.unit}', style: TextStyle(fontSize: 12, color: isLowStock ? Colors.red : Colors.grey)),
                const SizedBox(height: 4),
                // 条码打印按钮
                if (hasBarcode)
                  GestureDetector(
                    onTap: () => Get.toNamed('/barcode/print', arguments: {
                      'product': {
                        'barcode': product.barcode,
                        'name': product.name,
                        'spec': product.spec,
                        'salePrice': product.salePrice,
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.print, size: 12, color: Color(0xFF667eea)),
                          SizedBox(width: 2),
                          Text('条码', style: TextStyle(fontSize: 10, color: Color(0xFF667eea))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
