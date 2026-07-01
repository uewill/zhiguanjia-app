import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 商品选择器
class ProductSelector {
  /// 显示商品选择器
  static void show({
    required List<dynamic> products,
    required bool isLoading,
    required String Function(dynamic) priceGetter,
    required VoidCallback onRefresh,
    required VoidCallback onCreateNew,
    required Function(dynamic) onSelected,
  }) {
    Get.bottomSheet(
      _ProductSelectorContent(
        products: products,
        isLoading: isLoading,
        priceGetter: priceGetter,
        onRefresh: onRefresh,
        onCreateNew: onCreateNew,
        onSelected: onSelected,
      ),
    );
  }
}

/// 商品选择器内容
class _ProductSelectorContent extends StatefulWidget {
  final List<dynamic> products;
  final bool isLoading;
  final String Function(dynamic) priceGetter;
  final VoidCallback onRefresh;
  final VoidCallback onCreateNew;
  final Function(dynamic) onSelected;

  const _ProductSelectorContent({
    required this.products,
    required this.isLoading,
    required this.priceGetter,
    required this.onRefresh,
    required this.onCreateNew,
    required this.onSelected,
  });

  @override
  State<_ProductSelectorContent> createState() => _ProductSelectorContentState();
}

class _ProductSelectorContentState extends State<_ProductSelectorContent> {
  final searchController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  dynamic selectedProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TDText(
                    '选择商品',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '搜索商品名称、编码、条码',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          // 商品列表
          Expanded(
            child: widget.products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        TDText('暂无商品', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      final isSelected = selectedProduct == product;
                      
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        title: Text(product['name']?.toString() ?? ''),
                        subtitle: Text(
                          '编码: ${product['code']?.toString() ?? '-'} | 库存: ${product['stock'] ?? 0}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.priceGetter(product),
                              style: const TextStyle(
                                color: Color(0xFFF53F3F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              product['unit']?.toString() ?? '件',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectedProduct = product;
                          });
                        },
                      );
                    },
                  ),
          ),
          // 已选商品和数量输入
          if (selectedProduct != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TDText(
                    '已选: ${selectedProduct['name']?.toString() ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const TDText('数量:'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '输入数量',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TDButton(
                        text: '确认添加',
                        theme: TDButtonTheme.primary,
                        size: TDButtonSize.medium,
                        onTap: () {
                          widget.onSelected(selectedProduct);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // 新增商品按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TDButton(
              text: '新增商品',
              theme: TDButtonTheme.light,
              size: TDButtonSize.large,
              isBlock: true,
              icon: TDIcons.add,
              onTap: () {
                Get.back();
                widget.onCreateNew();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 商品选择器底部弹窗
class ProductSelectorBottomSheet extends StatefulWidget {
  final dynamic controller;
  final Function(dynamic, {int quantity}) onSelect;

  const ProductSelectorBottomSheet({
    Key? key,
    required this.controller,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<ProductSelectorBottomSheet> createState() => _ProductSelectorBottomSheetState();
}

class _ProductSelectorBottomSheetState extends State<ProductSelectorBottomSheet> {
  final searchController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  dynamic selectedProduct;

  @override
  void initState() {
    super.initState();
    widget.controller.loadProducts?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TDText(
                    '选择商品',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '搜索商品名称、编码、条码',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: (v) => widget.controller.searchProducts?.call(v),
            ),
          ),
          // 商品列表
          Expanded(
            child: Obx(() {
              final products = widget.controller.products ?? [];
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      TDText('暂无商品', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isSelected = selectedProduct == product;
                  
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text(product['name']?.toString() ?? ''),
                    subtitle: Text(
                      '编码: ${product['code']?.toString() ?? '-'} | 库存: ${product['stock'] ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥${(product['salePrice'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFF53F3F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product['unit']?.toString() ?? '件',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedProduct = product;
                      });
                    },
                  );
                },
              );
            }),
          ),
          // 已选商品和数量输入
          if (selectedProduct != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TDText(
                    '已选: ${selectedProduct['name']?.toString() ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const TDText('数量:'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '输入数量',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TDButton(
                        text: '确认添加',
                        theme: TDButtonTheme.primary,
                        size: TDButtonSize.medium,
                        onTap: () {
                          final qty = int.tryParse(quantityController.text) ?? 1;
                          widget.onSelect(selectedProduct, quantity: qty);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // 新增商品按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TDButton(
              text: '新增商品',
              theme: TDButtonTheme.light,
              size: TDButtonSize.large,
              isBlock: true,
              icon: TDIcons.add,
              onTap: () {
                Get.back();
                Get.toNamed('/product/form');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 简化商品选择器（只列表，无数量输入）
class SimpleProductSelector extends StatelessWidget {
  final String title;
  final List<dynamic> products;
  final Function(dynamic) onSelect;

  const SimpleProductSelector({
    Key? key,
    required this.title,
    required this.products,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TDText(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product['name']?.toString() ?? ''),
                  subtitle: Text('编码: ${product['code']?.toString() ?? '-'}'),
                  trailing: Text('¥${(product['price'] ?? 0).toStringAsFixed(2)}'),
                  onTap: () => onSelect(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}