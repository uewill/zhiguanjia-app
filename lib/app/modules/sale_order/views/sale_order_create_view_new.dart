import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/core/components/index.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../controllers/sale_order_controller_new.dart';

/// 销售单创建页面 - 使用模板方法模式
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
    Get.bottomSheet(
      _buildCustomerSelector(),
    );
  }

  Widget _buildCustomerSelector() {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TDText(
                    '选择客户',
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
          Expanded(
            child: Obx(() {
              if (_customerController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_customerController.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      TDText('暂无客户', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: _customerController.customers.length,
                itemBuilder: (context, index) {
                  final customer = _customerController.customers[index];
                  return ListTile(
                    title: Text(customer.name),
                    subtitle: customer.contact?.isNotEmpty == true
                        ? Text('联系人: ${customer.contact}')
                        : null,
                    trailing: customer.phone?.isNotEmpty == true
                        ? Text(customer.phone!)
                        : null,
                    onTap: () {
                      controller.selectPartner({
                        'id': customer.id,
                        'name': customer.name,
                        'contact': customer.contact,
                        'phone': customer.phone,
                      });
                      Get.back();
                    },
                  );
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TDButton(
              text: '新增客户',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              isBlock: true,
              icon: TDIcons.add,
              onTap: () {
                Get.back();
                Get.toNamed('/customer/form');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void _showWarehouseSelector({bool isFrom = true}) {
    _warehouseController.loadWarehouses();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const TDText(
                '选择出库仓库',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_warehouseController.warehouses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warehouse_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        TDText('暂无仓库', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: _warehouseController.warehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = _warehouseController.warehouses[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Text(warehouse.name),
                          if (warehouse.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2FC27D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '默认',
                                style: TextStyle(fontSize: 10, color: Color(0xFF2FC27D)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: warehouse.address != null
                          ? Text(warehouse.address!)
                          : null,
                      onTap: () {
                        controller.selectWarehouse({
                          'id': warehouse.id,
                          'name': warehouse.name,
                          'address': warehouse.address,
                          'isDefault': warehouse.isDefault,
                        });
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void _showProductSelector() {
    _productController.loadProducts();
    Get.bottomSheet(
      _buildProductSelector(),
    );
  }

  Widget _buildProductSelector() {
    return Container(
      height: Get.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TDInput(
              leftLabel: '',
              hintText: '搜索商品名称、编码',
              prefixIcon: const Icon(Icons.search),
              onChanged: (v) => _productController.searchProducts(v),
            ),
          ),
          Expanded(
            child: Obx(() {
              final products = _productController.filteredProducts.isNotEmpty
                  ? _productController.filteredProducts
                  : _productController.products;
              if (_productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
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
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text(product.name),
                    subtitle: Text('编码: ${product.code} | 库存: ${product.stock}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥${product.salePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFF53F3F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.unit,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    onTap: () {
                      _onProductSelected(product);
                    },
                  );
                },
              );
            }),
          ),
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

  void _onProductSelected(dynamic product) {
    final item = BillItem(
      productId: product.id,
      productName: product.name,
      productCode: product.code,
      unit: product.unit,
      quantity: 1,
      price: product.salePrice,
    );
    controller.addItem(item);
    Get.back();
    Get.snackbar('成功', '已添加 ${product.name}');
  }
}
