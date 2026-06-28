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
  Widget _buildWarehouseSections() {
    return Column(
      children: [
        // 调出仓库
        Obx(() => WarehouseSelector(
          label: '调出仓库',
          icon: Icons.warehouse_outlined,
          color: Colors.orange,
          selectedWarehouse: controller.selectedWarehouse,
          onSelect: () => _showFromWarehouseSelector(),
        )),
        const SizedBox(height: 16),
        // 调入仓库
        Obx(() => WarehouseSelector(
          label: '调入仓库',
          icon: Icons.warehouse,
          color: const Color(0xFF2FC27D),
          selectedWarehouse: controller.selectedToWarehouse,
          onSelect: () => _showToWarehouseSelector(),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showFromWarehouseSelector() {
    _warehouseController.loadWarehouses();
    WarehouseSelector.show(
      title: '选择调出仓库',
      warehouses: _warehouseController.warehouses,
      isLoading: _warehouseController.isLoading.value,
      onRefresh: () => _warehouseController.loadWarehouses(),
      onSelected: (warehouse) {
        controller.selectWarehouse({
          'id': warehouse.id,
          'name': warehouse.name,
          'address': warehouse.address,
          'isDefault': warehouse.isDefault,
        });
      },
    );
  }

  void _showToWarehouseSelector() {
    _warehouseController.loadWarehouses();
    final fromId = controller.selectedWarehouse.value?['id'];
    // 排除调出仓库
    final availableWarehouses = _warehouseController.warehouses
        .where((w) => w.id != fromId)
        .toList();
    
    WarehouseSelector.show(
      title: '选择调入仓库',
      warehouses: availableWarehouses,
      isLoading: _warehouseController.isLoading.value,
      onRefresh: () => _warehouseController.loadWarehouses(),
      onSelected: (warehouse) {
        controller.selectToWarehouse({
          'id': warehouse.id,
          'name': warehouse.name,
          'address': warehouse.address,
          'isDefault': warehouse.isDefault,
        });
      },
    );
  }

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
