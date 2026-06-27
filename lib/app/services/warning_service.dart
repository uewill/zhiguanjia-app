// 库存预警服务
import 'package:dio/dio.dart';
import '../data/models/warning_model.dart';
import 'api_service.dart';
import '../core/utils/logger.dart';

class WarningService {
  final ApiService _apiService;

  WarningService(this._apiService);

  // 获取预警列表
  Future<List<InventoryWarning>> getWarningList({
    int? type,
    bool? isRead,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _apiService.dio.get('/warnings', queryParameters: {
        if (type != null) 'type': type,
        if (isRead != null) 'isRead': isRead,
        'page': page,
        'size': size,
      });
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map((e) => InventoryWarning.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      Logger.e('获取预警列表失败', error: e);
      return _getMockWarnings();
    }
  }

  // 标记预警为已读
  Future<bool> markAsRead(String warningId) async {
    try {
      final response = await _apiService.dio.put('/warnings/$warningId/read');
      return response.data['code'] == 200;
    } catch (e) {
      Logger.e('标记已读失败', error: e);
      return false;
    }
  }

  // 标记所有为已读
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.dio.put('/warnings/read-all');
      return response.data['code'] == 200;
    } catch (e) {
      Logger.e('标记全部已读失败', error: e);
      return false;
    }
  }

  // 删除预警
  Future<bool> deleteWarning(String warningId) async {
    try {
      final response = await _apiService.dio.delete('/warnings/$warningId');
      return response.data['code'] == 200;
    } catch (e) {
      Logger.e('删除预警失败', error: e);
      return false;
    }
  }

  // 获取预警设置
  Future<WarningSetting?> getWarningSetting(int productId) async {
    try {
      final response = await _apiService.dio.get('/warnings/setting/$productId');
      if (response.data['code'] == 200) {
        return WarningSetting.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      Logger.e('获取预警设置失败', error: e);
      return null;
    }
  }

  // 保存预警设置
  Future<bool> saveWarningSetting(WarningSetting setting) async {
    try {
      final response = await _apiService.dio.post(
        '/warnings/setting',
        data: setting.toJson(),
      );
      return response.data['code'] == 200;
    } catch (e) {
      Logger.e('保存预警设置失败', error: e);
      return false;
    }
  }

  // 获取未读预警数量
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.dio.get('/warnings/unread-count');
      if (response.data['code'] == 200) {
        return response.data['data'] as int;
      }
      return 0;
    } catch (e) {
      Logger.e('获取未读数量失败', error: e);
      return 0;
    }
  }

  // Mock数据
  List<InventoryWarning> _getMockWarnings() {
    return [
      InventoryWarning(
        id: '1',
        productId: 1,
        productName: '可口可乐 500ml',
        warningType: WarningType.lowStock,
        warningTypeName: '库存不足',
        currentStock: 5,
        thresholdValue: 20,
        warehouseName: '主仓库',
        createTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InventoryWarning(
        id: '2',
        productId: 2,
        productName: '红牛维生素饮料',
        warningType: WarningType.stagnant,
        warningTypeName: '滞销预警',
        currentStock: 150,
        thresholdValue: 30,
        warehouseName: '主仓库',
        createTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InventoryWarning(
        id: '3',
        productId: 3,
        productName: '康师傅方便面',
        warningType: WarningType.expiry,
        warningTypeName: '临期预警',
        currentStock: 50,
        thresholdValue: 7,
        warehouseName: '主仓库',
        createTime: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
