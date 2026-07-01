import 'package:get/get.dart';
import 'bill_type.dart';
import 'bill_base.dart';

/// 单据页面模板方法接口
/// 子类必须实现这些方法来定义具体行为
abstract class BillCreatePageController {
  /// 单据类型配置
  BillType get billType;
  
  /// 当前日期
  Rx<DateTime> get billDate;
  
  /// 预计日期（选填）
  Rxn<DateTime> get expectedDate;
  
  /// 备注
  RxString get remark;
  
  /// 是否正在加载
  RxBool get isLoading;
  
  /// 选择日期
  void setBillDate(DateTime date);
  
  /// 选择预计日期
  void setExpectedDate(DateTime? date);
  
  /// 加载合作方列表（供应商/客户）
  Future<List<Map<String, dynamic>>> loadPartners();
  
  /// 加载仓库列表
  Future<List<Map<String, dynamic>>> loadWarehouses();
  
  /// 加载商品列表
  Future<List<Map<String, dynamic>>> loadProducts();
  
  /// 创建单据
  Future<bool> createBill();
  
  /// 验证单据数据
  String? validate();
  
  /// 构建单据对象
  BillBase buildBill();
}

/// 通用单据明细项模型
class BillItem {
  final int? id;
  final int productId;
  final String productName;
  final String? productCode;
  final String? unit;
  final RxInt quantity;
  final double? price;
  final double? amount;
  
  // 扩展字段：多单位、多规格支持
  final String? selectedUnit;
  final double? unitRatio;
  final Map<String, dynamic>? skuSpecs;

  BillItem({
    this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.unit,
    required int quantity,
    this.price,
    this.amount,
    this.selectedUnit,
    this.unitRatio,
    this.skuSpecs,
  }) : quantity = quantity.obs;

  double get subtotal => (price ?? 0) * quantity.value;
  
  String get displayName {
    if (selectedUnit != null) {
      return '$productName ($selectedUnit)';
    }
    return productName;
  }
  
  String get unitDisplay => selectedUnit ?? unit ?? '件';
  
  int get actualQuantity {
    if (unitRatio != null && unitRatio! > 0) {
      return (quantity.value * unitRatio!).round();
    }
    return quantity.value;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'productCode': productCode,
    'unit': unitDisplay,
    'quantity': quantity.value,
    'price': price,
    'amount': amount ?? subtotal,
    'unitRatio': unitRatio ?? 1.0,
    'skuSpecs': skuSpecs,
  };
}

/// 通用单据创建页面状态管理
abstract class BillCreateController extends GetxController implements BillCreatePageController {
  // 日期
  @override
  final Rx<DateTime> billDate = DateTime.now().obs;
  
  @override
  final Rxn<DateTime> expectedDate = Rxn<DateTime>();
  
  // 备注
  @override
  final RxString remark = ''.obs;
  
  // 加载状态
  @override
  final RxBool isLoading = false.obs;
  
  // 日期设置方法
  @override
  void setBillDate(DateTime date) => billDate.value = date;
  
  @override
  void setExpectedDate(DateTime? date) => expectedDate.value = date;
  
  // 合作方
  final Rxn<Map<String, dynamic>> selectedPartner = Rxn<Map<String, dynamic>>();
  
  // 仓库
  final Rxn<Map<String, dynamic>> selectedWarehouse = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> selectedToWarehouse = Rxn<Map<String, dynamic>>();
  
  // 明细项列表
  final RxList<BillItem> items = <BillItem>[].obs;
  
  // 经办人/业务员
  final Rxn<Map<String, dynamic>> selectedSalesman = Rxn<Map<String, dynamic>>();
  
  // 折扣和支付
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble paidAmount = 0.0.obs;

  // 计算属性
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity.value);
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get payableAmount => totalAmount - discountAmount.value;
  double get unpaidAmount => payableAmount - paidAmount.value;

  /// 选择合作方
  void selectPartner(Map<String, dynamic> partner) {
    selectedPartner.value = partner;
  }

  /// 选择经办人/业务员
  void selectSalesman(Map<String, dynamic> salesman) {
    selectedSalesman.value = salesman;
  }

  /// 选择仓库
  void selectWarehouse(Map<String, dynamic> warehouse) {
    selectedWarehouse.value = warehouse;
  }

  /// 选择目标仓库（调拨单用）
  void selectToWarehouse(Map<String, dynamic> warehouse) {
    selectedToWarehouse.value = warehouse;
  }

  /// 添加明细项
  void addItem(BillItem item) {
    // 检查是否已存在相同商品
    final existingIndex = items.indexWhere((i) => 
      i.productId == item.productId && 
      i.selectedUnit == item.selectedUnit &&
      _mapsEqual(i.skuSpecs, item.skuSpecs)
    );
    
    if (existingIndex >= 0) {
      items[existingIndex].quantity.value += item.quantity.value;
      items.refresh();
    } else {
      items.add(item);
    }
  }

  /// 更新明细项数量
  void updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      items[index].quantity.value = quantity;
      items.refresh();
    }
  }

  /// 更新明细项价格
  void updateItemPrice(int index, double price) {
    if (price < 0) return;
    items[index] = BillItem(
      id: items[index].id,
      productId: items[index].productId,
      productName: items[index].productName,
      productCode: items[index].productCode,
      unit: items[index].unit,
      quantity: items[index].quantity.value,
      price: price,
      selectedUnit: items[index].selectedUnit,
      unitRatio: items[index].unitRatio,
      skuSpecs: items[index].skuSpecs,
    );
    items.refresh();
  }

  /// 删除明细项
  void removeItem(int index) {
    items.removeAt(index);
  }

  /// 清空明细列表
  void clearItems() {
    items.clear();
  }

  /// 验证单据数据
  @override
  String? validate() {
    if (billType.requiresPartner && selectedPartner.value == null) {
      return '请选择${billType.partnerLabel}';
    }
    if (billType.requiresWarehouse && selectedWarehouse.value == null) {
      return '请选择${billType.warehouseLabel}';
    }
    if (billType.code == 'transfer' && selectedToWarehouse.value == null) {
      return '请选择调入仓库';
    }
    if (items.isEmpty) {
      return '请添加至少一个商品';
    }
    if (billType.code == 'transfer' && 
        selectedWarehouse.value?['id'] == selectedToWarehouse.value?['id']) {
      return '调出仓库和调入仓库不能相同';
    }
    return null;
  }

  /// 创建单据
  @override
  Future<bool> createBill() async {
    final error = validate();
    if (error != null) {
      Get.snackbar('提示', error);
      return false;
    }

    try {
      isLoading.value = true;
      final bill = buildBill();
      await submitBillToApi(bill);
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('错误', '创建失败: $e');
      return false;
    }
  }

  /// 提交单据到API - 子类实现
  Future<void> submitBillToApi(BillBase bill);

  bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    return a.entries.every((e) => b[e.key] == e.value);
  }
}
