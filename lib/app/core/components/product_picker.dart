import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../data/models/product_model.dart' show Product;

/// 商品选择结果回调
typedef OnProductSelected = void Function(Product product, double quantity, double price);
typedef OnProductsSelected = void Function(List<SelectedProduct> products);

/// 已选商品数据类
class SelectedProduct {
  final Product product;
  double quantity;
  double price;

  SelectedProduct({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get amount => quantity * price;
}

/// 统一商品选择组件
/// 支持单选/多选、搜索、分类筛选、数量/价格编辑
class ProductPicker extends StatefulWidget {
  final List<Product> products;
  final List<SelectedProduct>? initialSelected;
  final bool multiSelect;
  final bool showStock;
  final bool allowPriceEdit;
  final bool allowQuantityEdit;
  final Function(SelectedProduct)? onSingleSelected;
  final Function(List<SelectedProduct>)? onMultiSelected;

  const ProductPicker({
    Key? key,
    required this.products,
    this.initialSelected,
    this.multiSelect = true,
    this.showStock = true,
    this.allowPriceEdit = true,
    this.allowQuantityEdit = true,
    this.onSingleSelected,
    this.onMultiSelected,
  }) : super(key: key);

  /// 显示底部弹窗
  static Future<void> show({
    required List<Product> products,
    List<SelectedProduct>? initialSelected,
    bool multiSelect = true,
    bool showStock = true,
    bool allowPriceEdit = true,
    bool allowQuantityEdit = true,
    OnProductSelected? onSelected,
    OnProductsSelected? onMultiSelected,
  }) async {
    await Get.bottomSheet(
      ProductPicker(
        products: products,
        initialSelected: initialSelected,
        multiSelect: multiSelect,
        showStock: showStock,
        allowPriceEdit: allowPriceEdit,
        allowQuantityEdit: allowQuantityEdit,
        onSingleSelected: onSelected != null ? (sp) => onSelected(sp.product, sp.quantity, sp.price) : null,
        onMultiSelected: onMultiSelected,
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  @override
  State<ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<ProductPicker> {
  late final TextEditingController searchController;
  final RxString searchQuery = ''.obs;
  final RxList<SelectedProduct> selectedProducts = <SelectedProduct>[].obs;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    if (widget.initialSelected != null) {
      selectedProducts.addAll(widget.initialSelected!);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Product> get filteredProducts {
    if (searchQuery.value.isEmpty) return widget.products;
    return widget.products.where((p) {
      final query = searchQuery.value.toLowerCase();
      return p.name.toLowerCase().contains(query) ||
          p.code.toLowerCase().contains(query) ||
          (p.barcode?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏
          _buildHeader(),

          // 搜索栏
          _buildSearchBar(),

          // 已选商品
          if (widget.multiSelect && selectedProducts.isNotEmpty)
            _buildSelectedSection(),

          // 商品列表
          Expanded(child: _buildProductList()),

          // 底部操作栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Text(
            '选择商品',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TDInput(
        controller: searchController,
        leftIcon: const Icon(Icons.search),
        hintText: '搜索商品名称、编码、条码',
        onChanged: (v) => searchQuery.value = v,
        needClear: true,
      ),
    );
  }

  Widget _buildSelectedSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已选商品 (${selectedProducts.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () => selectedProducts.clear(),
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedProducts.map((sp) => Chip(
              label: Text('${sp.product.name} x${sp.quantity}'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => selectedProducts.remove(sp),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      final products = filteredProducts;
      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('未找到商品', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  Widget _buildProductItem(Product product) {
    final isSelected = selectedProducts.any((sp) => sp.product.id == product.id);

    return ListTile(
      leading: Checkbox(
        value: isSelected,
        onChanged: (v) => _toggleProduct(product),
      ),
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('编码: ${product.code}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          if (widget.showStock)
            Text('库存: ${product.stock}', style: TextStyle(fontSize: 12, color: Colors.blue)),
        ],
      ),
      trailing: Text(
        '¥${product.salePrice.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF53F3F),
        ),
      ),
      onTap: () {
        if (widget.multiSelect) {
          _toggleProduct(product);
        } else {
          _showQuantityPriceDialog(product);
        }
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => Row(
          children: [
            if (widget.multiSelect) ...[
              Text(
                '已选 ${selectedProducts.length} 件',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TDButton(
                text: '确定',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                onTap: () {
                  widget.onMultiSelected?.call(selectedProducts.toList());
                  Get.back();
                },
              ),
            ] else ...[
              const Spacer(),
              TDButton(
                text: '关闭',
                theme: TDButtonTheme.light,
                size: TDButtonSize.large,
                onTap: () => Get.back(),
              ),
            ],
          ],
        )),
      ),
    );
  }

  void _toggleProduct(Product product) {
    final index = selectedProducts.indexWhere((sp) => sp.product.id == product.id);
    if (index >= 0) {
      selectedProducts.removeAt(index);
    } else {
      selectedProducts.add(SelectedProduct(
        product: product,
        quantity: 1,
        price: product.salePrice,
      ));
    }
  }

  void _showQuantityPriceDialog(Product product) {
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: product.salePrice.toStringAsFixed(2),
    );

    Get.dialog(AlertDialog(
      title: Text(product.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.allowQuantityEdit)
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '数量',
                border: OutlineInputBorder(),
              ),
            ),
          if (widget.allowQuantityEdit && widget.allowPriceEdit)
            const SizedBox(height: 16),
          if (widget.allowPriceEdit)
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '单价',
                prefixText: '¥',
                border: OutlineInputBorder(),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final quantity = double.tryParse(quantityController.text) ?? 1;
            final price = double.tryParse(priceController.text) ?? 0;
            widget.onSingleSelected?.call(SelectedProduct(
              product: product,
              quantity: quantity,
              price: price,
            ));
            Get.back();
            Get.back(); // 关闭选择器
          },
          child: const Text('确定'),
        ),
      ],
    ));
  }
}
