import '../../core/network/api_client.dart';
import '../models/customer_model.dart';

/// 客户服务
class CustomerService {
  final ApiClient _client = ApiClient();

  /// 获取客户列表
  Future<List<Customer>> getCustomers({
    String? keyword,
    String? level,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/customers',
      queryParams: {
        if (keyword != null) 'keyword': keyword,
        if (level != null) 'level': level,
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.map((e) => Customer.fromJson(e)).toList();
  }

  /// 获取客户详情
  Future<Customer> getCustomer(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/customers/$id',
    );
    return Customer.fromJson(response);
  }

  /// 创建客户
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _client.post<Map<String, dynamic>>(
      path: '/customers',
      body: customer.toJson(),
    );
    return Customer.fromJson(response);
  }

  /// 更新客户
  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _client.put<Map<String, dynamic>>(
      path: '/customers/${customer.id}',
      body: customer.toJson(),
    );
    return Customer.fromJson(response);
  }

  /// 删除客户
  Future<void> deleteCustomer(int id) async {
    await _client.delete(path: '/customers/$id');
  }

  /// 获取客户应收款
  Future<Map<String, dynamic>> getReceivable(int customerId) async {
    return await _client.get<Map<String, dynamic>>(
      path: '/customers/$customerId/receivable',
    );
  }
}
