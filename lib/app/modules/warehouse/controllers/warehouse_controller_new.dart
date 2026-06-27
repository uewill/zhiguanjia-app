import 'package:get/get.dart';
import '../../../../app/core/data/index.dart';
import '../models/warehouse_model_new.dart';

/// 仓库管理控制器 - 使用抽象框架
class WarehouseControllerNew extends DataController<WarehouseModel> {
  @override
  DataPageConfig get config => DataPageConfig.warehouse;

  @override
  WarehouseModel fromJson(Map<String, dynamic> json) => 
      WarehouseModel.fromJson(json);

  @override
  List<WarehouseModel> getMockData() => [
    WarehouseModel(
      id: 1,
      name: '主仓库',
      code: 'CK001',
      address: '总部大楼1层',
      isDefault: true,
    ),
    WarehouseModel(
      id: 2,
      name: '门店仓库',
      code: 'CK002',
      address: '门店后院',
    ),
    WarehouseModel(
      id: 3,
      name: '退货仓',
      code: 'CK003',
      address: '总部大楼B1层',
    ),
  ];

  /// 获取默认仓库
  WarehouseModel? getDefaultWarehouse() {
    return items.firstWhereOrNull((w) => w.isDefault);
  }

  /// 设置默认仓库
  Future<void> setDefaultWarehouse(int id) async {
    // 取消其他仓库的默认状态
    for (var warehouse in items) {
      if (warehouse.isDefault && warehouse.id != id) {
        // 更新为非默认
      }
    }
    await refresh();
  }
}