import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/services/api_service.dart';

/// 销售单创建控制器 - 使用抽象框架
class SaleOrderControllerNew extends BillCreateController {
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  BillType get billType => BillType.sale;

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
      customerId: selectedPartner.value?['id'] ?? selectedPartner.value?.id,
      customerName: selectedPartner.value?['name'] ?? selectedPartner.value?.name,
      warehouseId: selectedWarehouse.value?['id'] ?? selectedWarehouse.value?.id,
      warehouseName: selectedWarehouse.value?['name'] ?? selectedWarehouse.value?.name,
      remark: remark.value,
      totalAmount: totalAmount,
      items: items.map((item) => SaleOrderItem(
        productId: item.productId,
        productName: item.productName,
        productCode: item.productCode,
        unit: item.unitDisplay,
        quantity: item.quantity.value,
        price: item.price ?? 0,
        amount: item.subtotal,
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
  final String id = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  DateTime billDate;
  @override
  int? partnerId;
  @override
  String? partnerName;
  @override
  int? warehouseId;
  @override
  String? warehouseName;
  @override
  String? remark;
  @override
  double totalAmount;
  @override
  List<BillItemBase> items;

  int? customerId;
  String? customerName;

  SaleOrderModel({
    required this.billDate,
    this.customerId,
    this.customerName,
    this.warehouseId,
    this.warehouseName,
    this.remark,
    required this.totalAmount,
    required this.items,
  }) {
    partnerId = customerId;
    partnerName = customerName;
  }

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'customerName': customerName,
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'billDate': billDate.toIso8601String(),
    'remark': remark,
    'totalAmount': totalAmount,
    'items': items.map((e) => {
      'productId': e.productId,
      'productName': e.productName,
      'quantity': e.quantity,
      'price': e.price,
      'amount': e.subtotal,
      'unit': e.unitDisplay,
    }).toList(),
  };
}

/// 销售单明细项
class SaleOrderItem implements BillItemBase {
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
  final double? price;

  SaleOrderItem({
    required this.productId,
    required this.productName,
    this.productCode,
    this.unit,
    required int quantity,
    this.price,
  }) {
    this.quantity.value = quantity;
  }

  @override
  double get subtotal => (price ?? 0) * quantity.value;

  @override
  String get unitDisplay => unit ?? '件';

  @override
  String get displayName => productName;

  @override
  set selectedUnit(String? value) {}

  @override
  String? get selectedUnit => unit;
}
