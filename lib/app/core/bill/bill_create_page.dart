import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_controller.dart';
import '../components/partner_selector.dart';
import '../components/warehouse_selector.dart';
import '../components/product_selector.dart';
import '../components/item_list.dart';
import '../components/bill_bottom_bar.dart';
import '../components/remark_card.dart';
import '../components/date_selector.dart';

/// 单据创建页面模板
/// 使用模板方法模式，子类只需要实现必要的方法
abstract class BillCreatePage<T extends BillCreateController> extends StatefulWidget {
  const BillCreatePage({Key? key}) : super(key: key);

  @override
  State<BillCreatePage<T>> createState() => BillCreatePageState<T>();
}

class BillCreatePageState<T extends BillCreateController> extends State<BillCreatePage<T>> {
  late final T controller;
  
  // 其他需要的控制器
  late final dynamic partnerController;
  late final dynamic warehouseController;
  late final dynamic productController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<T>();
    _initControllers();
  }

  void _initControllers() {
    // 初始化其他需要的控制器，安全注入
    _initPartnerController();
    _initWarehouseController();
    _initProductController();
  }

  void _initPartnerController() {
    // 子类可覆盖此方法来提供特定的控制器
    final partnerCtrl = getPartnerController();
    if (partnerCtrl != null) {
      partnerController = partnerCtrl;
    }
  }

  void _initWarehouseController() {
    final whCtrl = getWarehouseController();
    if (whCtrl != null) {
      warehouseController = whCtrl;
    }
  }

  void _initProductController() {
    final prodCtrl = getProductController();
    if (prodCtrl != null) {
      productController = prodCtrl;
    }
  }

  /// 子类可覆盖：获取合作方控制器
  dynamic getPartnerController() => null;
  
  /// 子类可覆盖：获取仓库控制器
  dynamic getWarehouseController() => null;
  
  /// 子类可覆盖：获取商品控制器
  dynamic getProductController() => null;

  @override
  Widget build(BuildContext context) {
    final billType = controller.billType;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: billType.title,
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left, 
            iconColor: Colors.white, 
            action: () => Get.back(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _buildSections(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// 构建页面部分 - 模板方法定义顺序
  List<Widget> _buildSections() {
    final sections = <Widget>[];
    final billType = controller.billType;

    // 1. 合作方选择（如果需要）
    if (billType.requiresPartner) {
      sections.add(_buildPartnerSection());
      sections.add(const SizedBox(height: 16));
    }

    // 2. 仓库选择（如果需要）
    if (billType.requiresWarehouse) {
      sections.addAll(_buildWarehouseSections());
    }

    // 3. 日期选择
    sections.add(_buildDateSection());
    sections.add(const SizedBox(height: 16));

    // 4. 明细列表
    sections.add(_buildItemsSection());
    sections.add(const SizedBox(height: 16));

    // 5. 备注
    sections.add(_buildRemarkSection());

    return sections;
  }

  /// 构建合作方选择部分 - 可覆盖
  Widget _buildPartnerSection() {
    return PartnerSelector(
      label: controller.billType.partnerLabel!,
      selectedPartner: controller.selectedPartner,
      primaryColor: controller.billType.primaryColor,
      onSelect: _showPartnerSelector,
    );
  }

  /// 构建仓库选择部分 - 可覆盖
  List<Widget> _buildWarehouseSections() {
    final billType = controller.billType;
    
    if (billType.code == 'transfer') {
      // 调拨单：显示两个仓库选择
      return [
        WarehouseSelector(
          label: '调出仓库',
          icon: Icons.warehouse_outlined,
          color: Colors.orange,
          selectedWarehouse: controller.selectedWarehouse,
          onSelect: () => _showWarehouseSelector(isFrom: true),
        ),
        const SizedBox(height: 16),
        WarehouseSelector(
          label: '调入仓库',
          icon: Icons.warehouse,
          color: const Color(0xFF2FC27D),
          selectedWarehouse: controller.selectedToWarehouse,
          onSelect: () => _showWarehouseSelector(isFrom: false),
        ),
        const SizedBox(height: 16),
      ];
    }
    
    // 普通单据：单个仓库选择
    return [
      WarehouseSelector(
        label: billType.warehouseLabel,
        icon: Icons.warehouse,
        color: const Color(0xFF2FC27D),
        selectedWarehouse: controller.selectedWarehouse,
        onSelect: () => _showWarehouseSelector(),
      ),
      const SizedBox(height: 16),
    ];
  }

  /// 构建日期选择部分 - 可覆盖
  Widget _buildDateSection() {
    return DateSelector(
      billDate: controller.billDate,
      expectedDate: controller.expectedDate,
      onBillDateChanged: controller.setBillDate,
      onExpectedDateChanged: controller.setExpectedDate,
    );
  }

  /// 构建明细列表部分 - 可覆盖
  Widget _buildItemsSection() {
    return ItemList(
      label: controller.billType.itemsLabel,
      items: controller.items,
      onAddItem: _showProductSelector,
      onUpdateQuantity: controller.updateItemQuantity,
      onRemoveItem: controller.removeItem,
    );
  }

  /// 构建备注部分 - 可覆盖
  Widget _buildRemarkSection() {
    return RemarkCard(
      remark: controller.remark,
      onChanged: (v) => controller.remark.value = v,
    );
  }

  /// 构建底部操作栏 - 可覆盖
  Widget _buildBottomBar() {
    return BillBottomBar(
      billType: controller.billType,
      totalQuantity: controller.totalQuantity,
      totalAmount: controller.totalAmount,
      onSubmit: () async {
        final success = await controller.createBill();
        if (success) {
          Get.back();
          Get.snackbar('成功', '${controller.billType.name}创建成功');
        }
      },
    );
  }

  /// 显示合作方选择器 - 子类实现
  void _showPartnerSelector() {
    // 默认实现，子类可覆盖
    if (partnerController != null) {
      partnerController.loadData?.call();
    }
    
    Get.bottomSheet(
      PartnerSelectorBottomSheet(
        title: '选择${controller.billType.partnerLabel}',
        controller: partnerController,
        onSelect: (partner) {
          controller.selectPartner(partner);
          Get.back();
        },
      ),
    );
  }

  /// 显示仓库选择器
  void _showWarehouseSelector({bool isFrom = true}) {
    if (warehouseController != null) {
      warehouseController.loadWarehouses?.call();
    }
    
    Get.bottomSheet(
      WarehouseSelectorBottomSheet(
        title: isFrom ? controller.billType.warehouseLabel : '调入仓库',
        controller: warehouseController,
        onSelect: (warehouse) {
          if (isFrom) {
            controller.selectWarehouse(warehouse);
          } else {
            controller.selectToWarehouse(warehouse);
          }
          Get.back();
        },
      ),
    );
  }

  /// 显示商品选择器 - 子类实现
  void _showProductSelector() {
    // 默认实现，子类可覆盖
    Get.bottomSheet(
      ProductSelectorBottomSheet(
        controller: productController,
        onSelect: _onProductSelected,
      ),
    );
  }

  /// 商品选择回调 - 子类可覆盖
  void _onProductSelected(dynamic product, {int quantity = 1}) {
    final item = BillItem(
      productId: product['id'] ?? product.id,
      productName: product['name'] ?? product.name,
      productCode: product['code'] ?? product.code,
      unit: product['unit'] ?? product.unit,
      quantity: quantity,
      price: product['price'] ?? product.salePrice ?? product.purchasePrice,
    );
    controller.addItem(item);
    Get.back();
  }
}
