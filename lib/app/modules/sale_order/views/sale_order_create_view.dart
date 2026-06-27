import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/sale_order_controller.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../data/models/product_model.dart';

class SaleOrderCreateView extends StatefulWidget {
  const SaleOrderCreateView({Key? key}) : super(key: key);

  @override
  State<SaleOrderCreateView> createState() => _SaleOrderCreateViewState();
}

class _SaleOrderCreateViewState extends State<SaleOrderCreateView> {
  final controller = Get.put(SaleOrderController());
  late final CustomerController customerController;
  late final WarehouseController warehouseController;
  late final ProductController productController;
  final remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 安全获取或初始化控制器
    customerController = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());
    warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '新建销售订单',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(icon: TDIcons.chevron_left, iconColor: Colors.white, action: () => Get.back()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 客户选择
                _buildCustomerCard(),
                const SizedBox(height: 16),
                // 出库仓库选择
                _buildWarehouseCard(),
                const SizedBox(height: 16),
                // 日期选择
                _buildDateCard(),
                const SizedBox(height: 16),
                // 销售商品列表
                _buildItemsCard(),
                const SizedBox(height: 16),
                // 备注
                _buildRemarkCard(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              TDText('客户', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final customer = controller.selectedCustomer.value;
            if (customer == null) {
              return TDButton(
                text: '选择客户',
                theme: TDButtonTheme.light,
                size: TDButtonSize.medium,
                isBlock: true,
                icon: TDIcons.add,
                onTap: _showCustomerSelector,
              );
            }
            return GestureDetector(
              onTap: _showCustomerSelector,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (customer.phone != null)
                            TDText('电话: ${customer.phone}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.purple),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWarehouseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warehouse, color: Color(0xFF2FC27D), size: 20),
              SizedBox(width: 8),
              TDText('出库仓库', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final warehouse = controller.selectedWarehouse.value;
            if (warehouse == null) {
              return TDButton(
                text: '选择仓库',
                theme: TDButtonTheme.light,
                size: TDButtonSize.medium,
                isBlock: true,
                icon: TDIcons.add,
                onTap: _showWarehouseSelector,
              );
            }
            return GestureDetector(
              onTap: _showWarehouseSelector,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2FC27D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(warehouse.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF2FC27D)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('订单日期', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: controller.orderDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                controller.setOrderDate(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TDText('${controller.orderDate.value.year}-${controller.orderDate.value.month.toString().padLeft(2, '0')}-${controller.orderDate.value.day.toString().padLeft(2, '0')}'),
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                ],
              ),
            ),
          )),
          const SizedBox(height: 12),
          const TDText('预计交货日期 (选填)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: controller.deliveryDate.value ?? DateTime.now().add(const Duration(days: 3)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                controller.setDeliveryDate(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TDText(controller.deliveryDate.value != null
                    ? '${controller.deliveryDate.value!.year}-${controller.deliveryDate.value!.month.toString().padLeft(2, '0')}-${controller.deliveryDate.value!.day.toString().padLeft(2, '0')}'
                    : '选择日期'),
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TDText('销售商品', style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => TDText('${controller.orderItems.length}种商品', style: const TextStyle(color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.orderItems.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    const TDText('暂无商品', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            return Column(
              children: controller.orderItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TDText(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TDText('单价: ¥${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => controller.updateItemQuantity(index, item.quantity - 1),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => controller.updateItemQuantity(index, item.quantity + 1),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => controller.removeItem(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 12),
          TDButton(
            text: '添加商品',
            theme: TDButtonTheme.light,
            size: TDButtonSize.medium,
            isBlock: true,
            icon: TDIcons.add,
            onTap: _showProductSelector,
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('备注', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TDInput(
            controller: remarkController,
            hintText: '输入备注信息（选填）',
            maxLines: 3,
            onChanged: (v) => controller.remark.value = v,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => TDText('共${controller.totalQuantity}件', style: const TextStyle(fontSize: 12))),
                  Obx(() => TDText('¥${controller.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2FC27D)))),
                ],
              ),
            ),
            TDButton(
              text: '提交订单',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: () async {
                final success = await controller.createOrder();
                if (success) {
                  Get.back();
                  Get.snackbar('成功', '销售订单创建成功');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSelector() {
    customerController.loadCustomers();
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
              child: const TDText('选择客户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: customerController.customers.length,
                itemBuilder: (context, index) {
                  final customer = customerController.customers[index];
                  return ListTile(
                    title: Text(customer.name),
                    subtitle: customer.phone != null ? Text(customer.phone!) : null,
                    onTap: () {
                      controller.selectCustomer(customer);
                      Get.back();
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarehouseSelector() {
    warehouseController.loadWarehouses();
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
              child: const TDText('选择出库仓库', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: warehouseController.warehouses.length,
                itemBuilder: (context, index) {
                  final warehouse = warehouseController.warehouses[index];
                  return ListTile(
                    title: Text(warehouse.name),
                    onTap: () {
                      controller.selectWarehouse(warehouse);
                      Get.back();
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelector() {
    productController.loadProducts();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const TDText('选择商品', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: productController.products.length,
                itemBuilder: (context, index) {
                  final product = productController.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('编码: ${product.code} | 库存: ${product.stock}'),
                    trailing: Text('¥${product.salePrice?.toStringAsFixed(2) ?? '0.00'}'),
                    onTap: () {
                      Get.back();
                      _showQuantityDialog(product);
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(Product product) {
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: product.salePrice?.toStringAsFixed(2) ?? '0.00');
    
    Get.dialog(
      AlertDialog(
        title: Text('添加 ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(hintText: '数量'),
              controller: qtyController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(hintText: '单价 (¥)'),
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 0;
              controller.addOrderItem(product, qty, price);
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
