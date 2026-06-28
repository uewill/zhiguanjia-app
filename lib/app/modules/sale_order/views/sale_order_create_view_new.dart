import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/core/components/index.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../controllers/sale_order_controller_new.dart';

/// 销售单创建页面 - 使用模板方法模式 + 新表单字段组件
class SaleOrderCreateViewNew extends BillCreatePage<SaleOrderControllerNew> {
  const SaleOrderCreateViewNew({Key? key}) : super(key: key);

  @override
  State<BillCreatePage<SaleOrderControllerNew>> createState() => 
    _SaleOrderCreateViewNewState();
}

class _SaleOrderCreateViewNewState extends BillCreatePageState<SaleOrderControllerNew> {
  late final CustomerController _customerController;
  late final WarehouseController _warehouseController;
  late final ProductController _productController;

  @override
  void initState() {
    super.initState();
    Get.put(SaleOrderControllerNew());
    _customerController = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());
    _warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    _productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
  }

  @override
  dynamic getPartnerController() => _customerController;

  @override
  dynamic getWarehouseController() => _warehouseController;

  @override
  dynamic getProductController() => _productController;

  @override
  void _showPartnerSelector() {
    _customerController.loadCustomers();
    CustomerSelector.show(
      customers: _customerController.customers,
      isLoading: _customerController.isLoading.value,
      onRefresh: () => _customerController.loadCustomers(),
      onCreateNew: () => Get.toNamed('/customer/form'),
      onSelected: (customer) {
        controller.selectPartner({
          'id': customer.id,
          'name': customer.name,
          'contact': customer.contact,
          'phone': customer.phone,
        });
      },
    );
  }

  @override
  void _showWarehouseSelector({bool isFrom = true}) {
    _warehouseController.loadWarehouses();
    WarehouseSelector.show(
      title: '选择出库仓库',
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
      priceGetter: (p) => '¥${p.salePrice?.toStringAsFixed(2) ?? '0.00'}',
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
      price: product.salePrice ?? 0,
    );
    controller.addItem(item);
    Get.back();
    Get.snackbar('成功', '已添加 ${product.name}');
  }
}
