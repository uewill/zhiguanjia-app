import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/services/api_service.dart';

/// 销售单创建控制器 - 使用抽象框架
class SaleOrderControllerNew extends BillCreateController {
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  BillType get billType => BillType.sales;

  @override
  Future<List<Map<String, dynamic>>> loadPartners() async {
    try {
      final response = await _apiService.get('/customers');
      if (response.data['code'] == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      return [
        {'id': 1, 'name': '零售客户', 'contact': '散客', 'phone': ''},
        {'id': 2, 'name': '永辉便利店', 'contact': '王老板', 'phone': '13900139001'},
        {'id': 3, 'name': '美佳超市', 'contact': '李经理', 'phone': '13900139002'},
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
        {'id': 1, 'name': '可口可乐', 'code': 'C001', 'unit': '瓶', 'salePrice': 3.5, 'stock': 100},
        {'id': 2, 'name': '红牛', 'code': 'C002', 'unit': '罐', 'salePrice': 6.0, 'stock': 50},
        {'id': 3, 'name': '方便面', 'code': 'C003', 'unit': '袋', 'salePrice': 4.0, 'stock': 80},
      ];
    }
    return [];
  }

  @override
  BillBase buildBill() {
    return SaleOrderModel(
      billDate: billDate.value,
      customerId: selectedPartner.value?['id'],
      customerName: selectedPartner.value?['name'],
      warehouseId: selectedWarehouse.value?['id'],
      warehouseName: selectedWarehouse.value?['name'],
      remark: remark.value,
      totalAmount: totalAmount,
      items: items.map((item) => SaleOrderItem(
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
    final saleOrder = bill as SaleOrderModel;
    final response = await _apiService.post(
      billType.apiEndpoint,
      data: saleOrder.toJson(),
    );
    if (response.data['code'] != 200) {
      throw Exception(response.data['message'] ?? '创建失败');
    }
  }
}

/// 销售单数据模型
class SaleOrderModel implements BillBase {
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

  int? customerId;
  String? customerName;

  SaleOrderModel({
    this.id,
    this.billNo,
    required this.billDate,
    this.customerId,
    this.customerName,
    this.warehouseId,
    this.warehouseName,
    this.remark,
    this.totalAmount,
    required this.items,
  }) {
    partnerId = customerId;
    partnerName = customerName;
  }

  @override
  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'customerName': customerName,
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'billDate': billDate.toIso8601String(),
    'remark': remark,
    'totalAmount': totalAmount,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

/// 销售单明细项
class SaleOrderItem implements BillItemBase {
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

  SaleOrderItem({
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
