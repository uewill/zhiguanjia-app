import '../../core/network/api_client.dart';
import '../models/purchase_order_model.dart';
import '../models/sale_order_model.dart';
import '../models/transfer_model.dart';

/// 订单服务 - 统一处理采购单、销售单、调拨单
class OrderService {
  final ApiClient _client = ApiClient();

  // ==================== 采购单 ====================
  
  /// 获取采购单列表
  Future<List<PurchaseOrder>> getPurchaseOrders({
    String? status,
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/purchase-orders',
      queryParams: {
        if (status != null) 'status': status,
        if (keyword != null) 'keyword': keyword,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.map((e) => PurchaseOrder.fromJson(e)).toList();
  }

  /// 创建采购单
  Future<PurchaseOrder> createPurchaseOrder(PurchaseOrder order) async {
    final response = await _client.post<Map<String, dynamic>>(
      path: '/purchase-orders',
      body: order.toJson(),
    );
    return PurchaseOrder.fromJson(response);
  }

  /// 更新采购单
  Future<PurchaseOrder> updatePurchaseOrder(PurchaseOrder order) async {
    final response = await _client.put<Map<String, dynamic>>(
      path: '/purchase-orders/${order.id}',
      body: order.toJson(),
    );
    return PurchaseOrder.fromJson(response);
  }

  /// 审核采购单
  Future<void> auditPurchaseOrder(int id) async {
    await _client.put(path: '/purchase-orders/$id/audit');
  }

  /// 入库采购单
  Future<void> inboundPurchaseOrder(int id) async {
    await _client.put(path: '/purchase-orders/$id/inbound');
  }

  /// 删除采购单
  Future<void> deletePurchaseOrder(int id) async {
    await _client.delete(path: '/purchase-orders/$id');
  }

  // ==================== 销售单 ====================
  
  /// 获取销售单列表
  Future<List<SaleOrder>> getSaleOrders({
    String? status,
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/sale-orders',
      queryParams: {
        if (status != null) 'status': status,
        if (keyword != null) 'keyword': keyword,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.map((e) => SaleOrder.fromJson(e)).toList();
  }

  /// 创建销售单
  Future<SaleOrder> createSaleOrder(SaleOrder order) async {
    final response = await _client.post<Map<String, dynamic>>(
      path: '/sale-orders',
      body: order.toJson(),
    );
    return SaleOrder.fromJson(response);
  }

  /// 更新销售单
  Future<SaleOrder> updateSaleOrder(SaleOrder order) async {
    final response = await _client.put<Map<String, dynamic>>(
      path: '/sale-orders/${order.id}',
      body: order.toJson(),
    );
    return SaleOrder.fromJson(response);
  }

  /// 审核销售单
  Future<void> auditSaleOrder(int id) async {
    await _client.put(path: '/sale-orders/$id/audit');
  }

  /// 出库销售单
  Future<void> outboundSaleOrder(int id) async {
    await _client.put(path: '/sale-orders/$id/outbound');
  }

  /// 删除销售单
  Future<void> deleteSaleOrder(int id) async {
    await _client.delete(path: '/sale-orders/$id');
  }

  // ==================== 调拨单 ====================
  
  /// 获取调拨单列表
  Future<List<TransferOrder>> getTransferOrders({
    String? status,
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/transfer-orders',
      queryParams: {
        if (status != null) 'status': status,
        if (keyword != null) 'keyword': keyword,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.map((e) => TransferOrder.fromJson(e)).toList();
  }

  /// 创建调拨单
  Future<TransferOrder> createTransferOrder(TransferOrder order) async {
    final response = await _client.post<Map<String, dynamic>>(
      path: '/transfer-orders',
      body: order.toJson(),
    );
    return TransferOrder.fromJson(response);
  }

  /// 更新调拨单
  Future<TransferOrder> updateTransferOrder(TransferOrder order) async {
    final response = await _client.put<Map<String, dynamic>>(
      path: '/transfer-orders/${order.id}',
      body: order.toJson(),
    );
    return TransferOrder.fromJson(response);
  }

  /// 审核调拨单
  Future<void> auditTransferOrder(int id) async {
    await _client.put(path: '/transfer-orders/$id/audit');
  }

  /// 确认调拨单
  Future<void> confirmTransferOrder(int id) async {
    await _client.put(path: '/transfer-orders/$id/confirm');
  }

  /// 删除调拨单
  Future<void> deleteTransferOrder(int id) async {
    await _client.delete(path: '/transfer-orders/$id');
  }
}
