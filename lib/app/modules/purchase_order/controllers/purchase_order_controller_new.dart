import 'package:get/get.dart';
import '../../../../app/core/bill/index.dart';
import '../../../../app/services/api_service.dart';
import '../../../../app/data/models/purchase_order_model.dart';

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
      supplierId: selectedPartner.value?['id'] ?? selectedPartner.value?.id,
      supplierName: selectedPartner.value?['name'] ?? selectedPartner.value?.name,
      warehouseId: selectedWarehouse.value?['id'] ?? selectedWarehouse.value?.id,
      warehouseName: selectedWarehouse.value?['name'] ?? selectedWarehouse.value?.name,
      remark: remark.value,
      totalAmount: totalAmount,
      items: items.map((item) => PurchaseOrderItem(
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
