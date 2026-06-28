import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/core/components/index.dart';
import '../../supplier/controllers/supplier_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../controllers/purchase_order_controller_new.dart';

/// 采购单创建页面 - 使用模板方法模式 + 新表单字段组件
class PurchaseOrderCreateViewNew extends BillCreatePage<PurchaseOrderControllerNew> {
  const PurchaseOrderCreateViewNew({Key? key}) : super(key: key);

  @override
  State<BillCreatePage<PurchaseOrderControllerNew>> createState() => 
    _PurchaseOrderCreateViewNewState();
}

class _PurchaseOrderCreateViewNewState extends BillCreatePageState<PurchaseOrderControllerNew> {
  late final SupplierController _supplierController;
  late final WarehouseController _warehouseController;
  late final ProductController _productController;

  @override
  void initState() {
    super.initState();
    Get.put(PurchaseOrderControllerNew());
    _supplierController = Get.isRegistered<SupplierController>()
        ? Get.find<SupplierController>()
        : Get.put(SupplierController());
    _warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    _productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
  }

  @override
  dynamic getPartnerController() => _supplierController;

  @override
  dynamic getWarehouseController() => _warehouseController;

  @override
  dynamic getProductController() => _productController;

  @override
  void _showPartnerSelector() {
    _supplierController.loadSuppliers();
    SupplierSelector.show(
      suppliers: _supplierController.suppliers,
      isLoading: _supplierController.isLoading.value,
      onRefresh: () => _supplierController.loadSuppliers(),
      onCreateNew: () => Get.toNamed('/supplier/form'),
      onSelected: (supplier) {
        controller.selectPartner({
          'id': supplier.id,
          'name': supplier.name,
          'contact': supplier.contact,
          'phone': supplier.phone,
        });
      },
    );
  }

  @override
  void _showWarehouseSelector({bool isFrom = true}) {
    _warehouseController.loadWarehouses();
    WarehouseSelector.show(
      title: '选择入库仓库',
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

  @override
  void _showProductSelector() {
    _productController.loadProducts();
    ProductSelector.show(
      products: _productController.filteredProducts.isNotEmpty
          ? _productController.filteredProducts
          : _productController.products,
      isLoading: _productController.isLoading.value,
      priceGetter: (p) => '¥${p.purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
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
      price: product.purchasePrice ?? 0,
    );
    controller.addItem(item);
    Get.back();
    Get.snackbar('成功', '已添加 ${product.name}');
  }
}
