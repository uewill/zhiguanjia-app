// 状态流转服务
import 'package:dio/dio.dart';
import '../data/models/workflow_model.dart';
import 'api_service.dart';

class WorkflowService {
  final ApiService _apiService;

  WorkflowService(this._apiService);

  // 执行状态流转
  Future<bool> transitionStatus({
    required int orderId,
    required String orderType,
    required int fromStatus,
    required int toStatus,
    String? reason,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/workflow/transition',
        data: {
          'orderId': orderId,
          'orderType': orderType,
          'fromStatus': fromStatus,
          'toStatus': toStatus,
          'reason': reason,
        },
      );
      return response.data['code'] == 200;
    } catch (e) {
      print('状态流转失败: $e');
      return false;
    }
  }

  // 获取单据状态历史
  Future<List<StatusHistory>> getStatusHistory(int orderId, String orderType) async {
    try {
      final response = await _apiService.dio.get(
        '/workflow/history',
        queryParameters: {
          'orderId': orderId,
          'orderType': orderType,
        },
      );
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map((e) => StatusHistory.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取状态历史失败: $e');
      return [];
    }
  }

  // 获取待审核列表
  Future<List<dynamic>> getPendingApprovals(String role) async {
    try {
      final response = await _apiService.dio.get(
        '/workflow/pending',
        queryParameters: {'role': role},
      );
      if (response.data['code'] == 200) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print('获取待审核列表失败: $e');
      return [];
    }
  }

  // 审核单据
  Future<bool> approveOrder({
    required int orderId,
    required String orderType,
    required bool approved,
    String? reason,
  }) async {
    final fromStatus = OrderStatus.pending;
    final toStatus = approved ? OrderStatus.approved : OrderStatus.rejected;
    return transitionStatus(
      orderId: orderId,
      orderType: orderType,
      fromStatus: fromStatus,
      toStatus: toStatus,
      reason: approved ? null : reason,
    );
  }
}
