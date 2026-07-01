import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/services/api_service.dart';

/// 调拨单创建控制器 - 使用抽象框架
class TransferControllerNew extends BillCreateController {
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  BillType get billType => BillType.transfer;

  @override
  Future<List<Map<String, dynamic>>> loadPartners() async {
    // 调拨单不需要往来单位
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
        {'id': 3, 'name': '门店仓库', 'isDefault': false},
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
        {'id': 1, 'name': '可口可乐', 'code': 'C001', 'unit': '瓶', 'stock': 100},
        {'id': 2, 'name': '红牛', 'code': 'C002', 'unit': '罐', 'stock': 50},
        {'id': 3, 'name': '方便面', 'code': 'C003', 'unit': '袋', 'stock': 80},
      ];
    }
    return [];
  }

  @override
  BillBase buildBill() {
    return TransferOrderModel(
      billDate: billDate.value,
      fromWarehouseId: selectedWarehouse.value?['id'],
      fromWarehouseName: selectedWarehouse.value?['name'],
      toWarehouseId: selectedToWarehouse.value?['id'],
      toWarehouseName: selectedToWarehouse.value?['name'],
      remark: remark.value,
      items: items.map((item) => TransferOrderItem(
        productId: item.productId,
        productName: item.productName,
        productCode: item.productCode,
        unit: item.unitDisplay,
        quantity: item.quantity.value,
      )).toList(),
    );
  }

  @override
  Future<void> submitBillToApi(BillBase bill) async {
    final transfer = bill as TransferOrderModel;
    final response = await _apiService.post(
      billType.apiEndpoint,
      data: transfer.toJson(),
    );
    if (response.data['code'] != 200) {
      throw Exception(response.data['message'] ?? '创建失败');
    }
  }
}

/// 调拨单数据模型
class TransferOrderModel implements BillBase {
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
  final int? partnerId = null;
  @override
  final String? partnerName = null;
  @override
  int? warehouseId;
  @override
  String? warehouseName;
  @override
  int? toWarehouseId;
  @override
  String? toWarehouseName;
  @override
  final double? totalAmount = 0;
  @override
  final double? discountAmount = 0;
  @override
  final double? payableAmount = null;
  @override
  final double? paidAmount = null;
  @override
  List<BillItemBase> items;

  int? fromWarehouseId;
  String? fromWarehouseName;

  TransferOrderModel({
    this.id,
    this.billNo,
    required this.billDate,
    this.fromWarehouseId,
    this.fromWarehouseName,
    this.toWarehouseId,
    this.toWarehouseName,
    this.remark,
    required this.items,
  }) {
    warehouseId = fromWarehouseId;
    warehouseName = fromWarehouseName;
  }

  @override
  Map<String, dynamic> toJson() => {
    'fromWarehouseId': fromWarehouseId,
    'fromWarehouseName': fromWarehouseName,
    'toWarehouseId': toWarehouseId,
    'toWarehouseName': toWarehouseName,
    'billDate': billDate.toIso8601String(),
    'remark': remark,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

/// 调拨单明细项
class TransferOrderItem implements BillItemBase {
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
  final double? price = null;
  @override
  double? get amount => null;

  TransferOrderItem({
    this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.unit,
    required this.quantity,
  });

  @override
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'productCode': productCode,
    'unit': unit,
    'quantity': quantity,
  };
}
