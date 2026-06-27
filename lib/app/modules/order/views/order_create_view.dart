import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../services/api_service.dart';

// 扩展的购物车项 - 支持多单位、多规格
class CartItem {
  final Product product;
  int quantity;
  double price;
  
  // 多单位支持
  String? selectedUnit;  // 选择的单位名称（null表示基础单位）
  double? unitRatio;     // 单位转换比例
  
  // 多规格支持
  ProductSku? selectedSku;  // 选择的SKU
  
  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
    this.selectedUnit,
    this.unitRatio,
    this.selectedSku,
  });

  double get subtotal => price * quantity;
  
  String get displayName {
    if (selectedSku != null) {
      return '${product.name} (${selectedSku!.specText})';
    }
    return product.name;
  }
  
  String get unitDisplay {
    if (selectedUnit != null) return selectedUnit!;
    return product.unit;
  }
  
  // 获取实际库存扣减数量（考虑单位转换）
  int get actualStockQuantity {
    if (unitRatio != null && unitRatio! > 0) {
      return (quantity * unitRatio!).round();
    }
    return quantity;
  }
  
  // 用于API提交的数据
  Map<String, dynamic> toOrderItemJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'price': price,
      'unit': unitDisplay,
      'unitRatio': unitRatio ?? 1.0,
      'skuId': selectedSku?.id,
      'skuSpecs': selectedSku?.specs,
    };
  }
}

class OrderCreateController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final orderType = 'sale'.obs;
  final selectedCustomer = Rxn<Customer>();
  final cartItems = <CartItem>[].obs;
  final products = <Product>[].obs;

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.subtotal);
  int get totalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get totalActualQuantity => cartItems.fold(0, (sum, item) => sum + item.actualStockQuantity);

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final response = await _apiService.get('/products');
      if (response.data['code'] == 200) {
        products.value = (response.data['data']['list'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      products.value = _getMockProducts();
    }
  }

  void setOrderType(String type) {
    orderType.value = type;
    selectedCustomer.value = null;
  }

  void selectCustomer(Customer customer) {
    selectedCustomer.value = customer;
  }

  // 添加基础商品到购物车
  void addToCart(Product product, int quantity) {
    final price = orderType.value == 'sale' ? product.salePrice : product.purchasePrice;
    
    // 检查是否已存在相同商品（基础单位）
    final existingIndex = cartItems.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedUnit == null && 
      item.selectedSku == null
    );
    
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        price: price,
      ));
    }
  }

  // 添加多单位商品到购物车
  void addMultiUnitToCart(Product product, ProductUnit unit, int quantity) {
    final price = orderType.value == 'sale' 
        ? (unit.salePrice ?? product.salePrice * unit.ratio)
        : (unit.purchasePrice ?? product.purchasePrice * unit.ratio);
    
    // 检查是否已存在相同单位
    final existingIndex = cartItems.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedUnit == unit.name
    );
    
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        price: price,
        selectedUnit: unit.name,
        unitRatio: unit.ratio,
      ));
    }
  }

  // 添加多规格SKU到购物车
  void addSkuToCart(Product product, ProductSku sku, int quantity) {
    final price = orderType.value == 'sale' ? sku.salePrice : sku.purchasePrice;
    
    // 检查是否已存在相同SKU
    final existingIndex = cartItems.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedSku?.id == sku.id
    );
    
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        price: price,
        selectedSku: sku,
      ));
    }
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index].quantity = quantity;
      cartItems.refresh();
    }
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  Future<void> submitOrder() async {
    if (selectedCustomer.value == null) {
      Get.snackbar('提示', '请选择${orderType.value == 'sale' ? '客户' : '供应商'}');
      return;
    }
    if (cartItems.isEmpty) {
      Get.snackbar('提示', '请添加商品');
      return;
    }

    try {
      final orderData = {
        'type': orderType.value,
        'customerId': selectedCustomer.value!.id,
        'items': cartItems.map((item) => item.toOrderItemJson()).toList(),
        'totalAmount': totalAmount,
        'totalQuantity': totalQuantity,
        'totalActualQuantity': totalActualQuantity,
      };

      await _apiService.post('/orders', data: orderData);
      Get.snackbar('成功', '订单创建成功');
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('失败', '创建失败: $e');
    }
  }

  List<Product> _getMockProducts() {
    return [
      Product(id: 1, name: '可口可乐', code: 'C001', barcode: '123456', category: '饮料', unit: '瓶', salePrice: 3.5, purchasePrice: 2.8, stock: 100, minStock: 10),
      Product(id: 2, name: '红牛', code: 'C002', barcode: '234567', category: '饮料', unit: '罐', salePrice: 6.0, purchasePrice: 4.5, stock: 50, minStock: 5),
      Product(id: 3, name: '方便面', code: 'C003', barcode: '345678', category: '食品', unit: '袋', salePrice: 4.5, purchasePrice: 3.2, stock: 80, minStock: 10),
      Product(id: 4, name: '薯片', code: 'C004', barcode: '456789', category: '零食', unit: '袋', salePrice: 8.0, purchasePrice: 5.5, stock: 60, minStock: 5),
    ];
  }
}

class OrderCreateView extends GetView<OrderCreateController> {
  const OrderCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrderCreateController());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildOrderTypeSelector(),
                  _buildCustomerSelector(),
                  _buildProductSelector(),
                  _buildCartList(),
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
              child: TDText(
                '新建订单',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('订单类型', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.setOrderType('sale'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.orderType.value == 'sale' ? const Color(0xFF2FC27D) : const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TDText(
                        '销售出库',
                        style: TextStyle(
                          color: controller.orderType.value == 'sale' ? Colors.white : const Color(0xFF4E5969),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.setOrderType('purchase'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.orderType.value == 'purchase' ? const Color(0xFF2FC27D) : const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TDText(
                        '采购入库',
                        style: TextStyle(
                          color: controller.orderType.value == 'purchase' ? Colors.white : const Color(0xFF4E5969),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => TDText(
            controller.orderType.value == 'sale' ? '选择客户' : '选择供应商',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )),
          const SizedBox(height: 12),
          Obx(() => GestureDetector(
            onTap: () => _showCustomerPicker(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E6EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.orderType.value == 'sale' ? Icons.person : Icons.business,
                    color: const Color(0xFF86909C),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TDText(
                      controller.selectedCustomer.value?.name ??
                          '请选择${controller.orderType.value == 'sale' ? '客户' : '供应商'}',
                      style: TextStyle(
                        color: controller.selectedCustomer.value != null
                            ? const Color(0xFF1D2129)
                            : const Color(0xFF86909C),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF86909C)),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProductSelector() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TDText('选择商品', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              TDButton(
                text: '添加商品',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.small,
                onTap: () => _showProductPicker(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                const TDText('购物车为空', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.cartItems.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = controller.cartItems[index];
            return _buildCartItem(index, item);
          },
        ),
      );
    });
  }

  Widget _buildCartItem(int index, CartItem item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Color(0xFF86909C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(item.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TDText('¥${item.price.toStringAsFixed(2)}/${item.unitDisplay}', 
                        style: const TextStyle(color: Color(0xFFF53F3F), fontSize: 12)),
                    if (item.selectedSku != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const TDText('SKU', style: TextStyle(fontSize: 10, color: Color(0xFF1976D2))),
                      ),
                    ],
                    if (item.selectedUnit != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const TDText('多单位', style: TextStyle(fontSize: 10, color: Color(0xFF7B1FA2))),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.updateQuantity(index, item.quantity - 1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E6EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TDText('${item.quantity}'),
              ),
              GestureDetector(
                onTap: () => controller.updateQuantity(index, item.quantity + 1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC27D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => TDText(
                    '共 ${controller.totalQuantity} 件 | 实际 ${controller.totalActualQuantity} ${controller.cartItems.isNotEmpty ? controller.cartItems.first.product.unit : ""}',
                    style: const TextStyle(color: Color(0xFF86909C), fontSize: 12),
                  )),
                  Obx(() => TDText(
                    '¥${controller.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF53F3F),
                    ),
                  )),
                ],
              ),
            ),
            TDButton(
              text: '提交订单',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: () => controller.submitOrder(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker() {
    final customers = [
      Customer(id: 1, name: '张三客户', phone: '13800138001'),
      Customer(id: 2, name: '李四客户', phone: '13800138002'),
      Customer(id: 3, name: '可口可乐供应商', phone: '13800138003'),
      Customer(id: 4, name: '红牛供应商', phone: '13800138004'),
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => TDText(
                    '选择${controller.orderType.value == 'sale' ? '客户' : '供应商'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  title: TDText(customer.name),
                  subtitle: TDText(customer.phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    controller.selectCustomer(customer);
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

  void _showProductPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TDText('选择商品', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Obx(() => Expanded(
              child: ListView.builder(
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _buildProductListItem(product);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    final hasMultiUnit = product.units != null && product.units!.isNotEmpty;
    final hasMultiSku = product.hasSku == true && product.skus != null && product.skus!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TDText(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TDText('编码: ${product.code} | 库存: ${product.stock} ${product.unit}', 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
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
          const SizedBox(height: 12),
          // 基础单位选择
          Row(
            children: [
              Expanded(
                child: TDText('¥${product.salePrice}/${product.unit}', 
                    style: const TextStyle(color: Color(0xFFF53F3F), fontWeight: FontWeight.bold)),
              ),
              TDButton(
                text: '添加',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.small,
                onTap: () {
                  controller.addToCart(product, 1);
                  Get.back();
                },
              ),
            ],
          ),
          // 多单位选择
          if (hasMultiUnit) ...[
            const Divider(height: 16),
            const TDText('其他单位:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...product.units!.map((unit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TDText('${unit.name} (1:${unit.ratio})', style: const TextStyle(fontSize: 13)),
                        if (unit.barcode != null)
                          TDText('条码: ${unit.barcode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  TDText('¥${unit.salePrice?.toStringAsFixed(2) ?? (product.salePrice * unit.ratio).toStringAsFixed(2)}', 
                      style: const TextStyle(color: Color(0xFFF53F3F))),
                  const SizedBox(width: 8),
                  TDButton(
                    text: '添加',
                    theme: TDButtonTheme.light,
                    size: TDButtonSize.small,
                    onTap: () {
                      controller.addMultiUnitToCart(product, unit, 1);
                      Get.back();
                    },
                  ),
                ],
              ),
            )).toList(),
          ],
          // 多规格选择
          if (hasMultiSku) ...[
            const Divider(height: 16),
            const TDText('选择规格:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...product.skus!.map((sku) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TDText(sku.specText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        TDText('库存: ${sku.stock}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  TDText('¥${sku.salePrice.toStringAsFixed(2)}', 
                      style: const TextStyle(color: Color(0xFFF53F3F))),
                  const SizedBox(width: 8),
                  TDButton(
                    text: '添加',
                    theme: TDButtonTheme.light,
                    size: TDButtonSize.small,
                    onTap: () {
                      controller.addSkuToCart(product, sku, 1);
                      Get.back();
                    },
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }
}
