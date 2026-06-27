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
      fromWarehouseId: selectedWarehouse.value?['id'] ?? selectedWarehouse.value?.id,
      fromWarehouseName: selectedWarehouse.value?['name'] ?? selectedWarehouse.value?.name,
      toWarehouseId: selectedToWarehouse.value?['id'] ?? selectedToWarehouse.value?.id,
      toWarehouseName: selectedToWarehouse.value?['name'] ?? selectedToWarehouse.value?.name,
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
  final String id = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  DateTime billDate;
  @override
  int? partnerId; // 不需要
  @override
  String? partnerName; // 不需要
  @override
  int? warehouseId; // 调出仓库
  @override
  String? warehouseName;
  @override
  String? remark;
  @override
  double totalAmount = 0; // 调拨单无金额
  @override
  List<BillItemBase> items;

  int? fromWarehouseId;
  String? fromWarehouseName;
  int? toWarehouseId;
  String? toWarehouseName;

  TransferOrderModel({
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

  Map<String, dynamic> toJson() => {
    'fromWarehouseId': fromWarehouseId,
    'fromWarehouseName': fromWarehouseName,
    'toWarehouseId': toWarehouseId,
    'toWarehouseName': toWarehouseName,
    'billDate': billDate.toIso8601String(),
    'remark': remark,
    'items': items.map((e) => {
      'productId': e.productId,
      'productName': e.productName,
      'quantity': e.quantity,
      'unit': e.unitDisplay,
    }).toList(),
  };
}

/// 调拨单明细项
class TransferOrderItem implements BillItemBase {
  @override
  final int productId;
  @override
  final String productName;
  @override
  final String? productCode;
  @override
  final String? unit;
  @override
  final RxInt quantity = 1.obs;
  @override
  final double? price = null; // 调拨单无单价

  TransferOrderItem({
    required this.productId,
    required this.productName,
    this.productCode,
    this.unit,
    required int quantity,
  }) {
    this.quantity.value = quantity;
  }

  @override
  double get subtotal => 0; // 调拨单无金额

  @override
  String get unitDisplay => unit ?? '件';

  @override
  String get displayName => productName;

  @override
  set selectedUnit(String? value) {}

  @override
  String? get selectedUnit => unit;
}
