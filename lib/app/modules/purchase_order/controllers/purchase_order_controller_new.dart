import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/services/api_service.dart';

/// 采购单创建控制器 - 使用抽象框架
class PurchaseOrderControllerNew extends BillCreateController {
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  BillType get billType => BillType.purchase;

  @override
  Future<List<Map<String, dynamic>>> loadPartners() async {
    try {
      final response = await _apiService.get('/suppliers');
      if (response.data['code'] == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      // 使用模拟数据
      return [
        {'id': 1, 'name': '可口可乐供应商', 'contact': '张经理', 'phone': '13800138001'},
        {'id': 2, 'name': '红牛供应商', 'contact': '李经理', 'phone': '13800138002'},
        {'id': 3, 'name': '泡面供应商', 'contact': '王经理', 'phone': '13800138003'},
      ];
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> loadWarehouses() async {
    try {
      final response = await _apiService.get('/warehouses');
      if (response.data['code'] == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      return [
        {'id': 1, 'name': '主仓库', 'isDefault': true},
        {'id': 2, 'name': '分仓库', 'isDefault': false},
      ];
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> loadProducts() async {
    try {
      final response = await _apiService.get('/products');
      if (response.data['code'] == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']['list'] ?? []);
      }
    } catch (e) {
      return [
        {'id': 1, 'name': '可口可乐', 'code': 'C001', 'unit': '瓶', 'purchasePrice': 2.8, 'stock': 100},
        {'id': 2, 'name': '红牛', 'code': 'C002', 'unit': '罐', 'purchasePrice': 4.5, 'stock': 50},
        {'id': 3, 'name': '方便面', 'code': 'C003', 'unit': '袋', 'purchasePrice': 3.2, 'stock': 80},
      ];
    }
    return [];
  }

  @override
  BillBase buildBill() {
    return PurchaseOrderModel(
      billDate: billDate.value,
      supplierId: selectedPartner.value?['id'],
      supplierName: selectedPartner.value?['name'],
      warehouseId: selectedWarehouse.value?['id'],
      warehouseName: selectedWarehouse.value?['name'],
      remark: remark.value,
      totalAmount: totalAmount,
      items: items.map((item) => PurchaseOrderItem(
        productId: item.productId,
        productName: item.productName,
        productCode: item.productCode,
        unit: item.unitDisplay,
        quantity: item.quantity.value,
        price: item.price ?? 0,
      )).toList(),
    );
  }

  @override
  Future<void> submitBillToApi(BillBase bill) async {
    final purchaseOrder = bill as PurchaseOrderModel;
    final response = await _apiService.post(
      billType.apiEndpoint,
      data: purchaseOrder.toJson(),
    );
    if (response.data['code'] != 200) {
      throw Exception(response.data['message'] ?? '创建失败');
    }
  }
}

/// 采购单数据模型
class PurchaseOrderModel implements BillBase {
  @override
  final int? id;
  @override
  final String? billNo;
  @override
  DateTime billDate;
  @override
  final String status = 'pending';
  @override
  String? remark;
  @override
  int? partnerId;
  @override
  String? partnerName;
  @override
  int? warehouseId;
  @override
  String? warehouseName;
  @override
  final int? toWarehouseId = null;
  @override
  final String? toWarehouseName = null;
  @override
  double? totalAmount;
  @override
  final double? discountAmount = 0;
  @override
  final double? payableAmount = null;
  @override
  final double? paidAmount = null;
  @override
  List<BillItemBase> items;

  int? supplierId;
  String? supplierName;

  PurchaseOrderModel({
    this.id,
    this.billNo,
    required this.billDate,
    this.supplierId,
    this.supplierName,
    this.warehouseId,
    this.warehouseName,
    this.remark,
    this.totalAmount,
    required this.items,
  }) {
    partnerId = supplierId;
    partnerName = supplierName;
  }

  @override
  Map<String, dynamic> toJson() => {
    'supplierId': supplierId,
    'supplierName': supplierName,
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'billDate': billDate.toIso8601String(),
    'remark': remark,
    'totalAmount': totalAmount,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

/// 采购单明细项
class PurchaseOrderItem implements BillItemBase {
  @override
  final int? id;
  @override
  final int? productId;
  @override
  final String productName;
  @override
  final String? productCode;
  @override
  final String? unit;
  @override
  final int quantity;
  @override
  final double? price;
  @override
  double? get amount => (price ?? 0) * quantity;

  PurchaseOrderItem({
    this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.unit,
    required this.quantity,
    this.price,
  });

  @override
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'productCode': productCode,
    'unit': unit,
    'quantity': quantity,
    'price': price,
    'amount': amount,
  };
}
