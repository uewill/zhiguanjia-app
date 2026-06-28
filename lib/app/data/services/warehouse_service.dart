import '../../core/network/api_client.dart';

/// 仓库服务
class WarehouseService {
  final ApiClient _client = ApiClient();

  /// 获取仓库列表
  Future<List<Map<String, dynamic>>> getWarehouses({
    String? keyword,
    int page = 1,
    int size = 50,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/warehouses',
      queryParams: {
        if (keyword != null) 'keyword': keyword,
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// 获取仓库详情
  Future<Map<String, dynamic>> getWarehouse(int id) async {
    return await _client.get<Map<String, dynamic>>(path: '/warehouses/$id');
  }

  /// 创建仓库
  Future<Map<String, dynamic>> createWarehouse(Map<String, dynamic> data) async {
    return await _client.post<Map<String, dynamic>>(
      path: '/warehouses',
      body: data,
    );
  }

  /// 更新仓库
  Future<Map<String, dynamic>> updateWarehouse(int id, Map<String, dynamic> data) async {
    return await _client.put<Map<String, dynamic>>(
      path: '/warehouses/$id',
      body: data,
    );
  }

  /// 删除仓库
  Future<void> deleteWarehouse(int id) async {
    await _client.delete(path: '/warehouses/$id');
  }

  /// 获取库存列表
  Future<List<Map<String, dynamic>>> getInventory({
    int? warehouseId,
    int? productId,
    String? keyword,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/inventory',
      queryParams: {
        if (warehouseId != null) 'warehouseId': warehouseId.toString(),
        if (productId != null) 'productId': productId.toString(),
        if (keyword != null) 'keyword': keyword,
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// 获取库存明细
  Future<Map<String, dynamic>> getInventoryDetail(int id) async {
    return await _client.get<Map<String, dynamic>>(path: '/inventory/$id');
  }

  /// 盘点库存
  Future<void> checkStock(int inventoryId, double actualQty, {String? remark}) async {
    await _client.post(
      path: '/inventory/$inventoryId/check',
      body: {
        'actualQty': actualQty,
        if (remark != null) 'remark': remark,
      },
    );
  }
}
