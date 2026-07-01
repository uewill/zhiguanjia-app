import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/core/components/index.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../controllers/transfer_controller_new.dart';

/// 调拨单创建页面 - 使用模板方法模式 + 新表单字段组件
class TransferCreateViewNew extends BillCreatePage<TransferControllerNew> {
  const TransferCreateViewNew({Key? key}) : super(key: key);

  @override
  State<BillCreatePage<TransferControllerNew>> createState() => 
    _TransferCreateViewNewState();
}

class _TransferCreateViewNewState extends BillCreatePageState<TransferControllerNew> {
  late final WarehouseController _warehouseController;
  late final ProductController _productController;

  @override
  void initState() {
    super.initState();
    Get.put(TransferControllerNew());
    _warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    _productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
  }

  @override
  dynamic getWarehouseController() => _warehouseController;

  @override
  dynamic getProductController() => _productController;

  @override
  void _showProductSelector() {
    _productController.loadProducts();
    ProductSelector.show(
      products: _productController.filteredProducts.isNotEmpty
          ? _productController.filteredProducts
          : _productController.products,
      isLoading: _productController.isLoading.value,
      priceGetter: (p) => '', // 调拨单不显示价格
      onRefresh: () => _productController.loadProducts(),
      onCreateNew: () => Get.toNamed('/product/form'),
      onSelected: (product) => _onProductSelected(product),
    );
  }

  void _onProductSelected(dynamic product) {
    final item = BillItem(
      productId: product.id,
      productName: product.name,
      productCode: product.code,
      unit: product.unit,
      quantity: 1,
      price: null, // 调拨单无单价
    );
    controller.addItem(item);
    Get.back();
    Get.snackbar('成功', '已添加 ${product.name}');
  }
}
