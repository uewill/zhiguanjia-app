import '../../core/network/api_client.dart';

/// 供应商服务
class SupplierService {
  final ApiClient _client = ApiClient();

  /// 获取供应商列表
  Future<List<Map<String, dynamic>>> getSuppliers({
    String? keyword,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/suppliers',
      queryParams: {
        if (keyword != null) 'keyword': keyword,
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// 获取供应商详情
  Future<Map<String, dynamic>> getSupplier(int id) async {
    return await _client.get<Map<String, dynamic>>(path: '/suppliers/$id');
  }

  /// 创建供应商
  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    return await _client.post<Map<String, dynamic>>(
      path: '/suppliers',
      body: data,
    );
  }

  /// 更新供应商
  Future<Map<String, dynamic>> updateSupplier(int id, Map<String, dynamic> data) async {
    return await _client.put<Map<String, dynamic>>(
      path: '/suppliers/$id',
      body: data,
    );
  }

  /// 删除供应商
  Future<void> deleteSupplier(int id) async {
    await _client.delete(path: '/suppliers/$id');
  }
}
