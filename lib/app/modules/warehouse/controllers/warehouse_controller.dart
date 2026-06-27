import 'package:get/get.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

class WarehouseController extends GetxController {
  final api = Get.find<ApiService>();
  
  final warehouses = <Warehouse>[].obs;
  final isLoading = false.obs;
  final selectedWarehouse = Rxn<Warehouse>();

  @override
  void onInit() {
    super.onInit();
    loadWarehouses();
  }

  Future<void> loadWarehouses() async {
    isLoading.value = true;
    try {
      final response = await api.get('/warehouses');
      if (response.data != null && response.data['data'] != null) {
        warehouses.value = (response.data['data'] as List)
            .map((e) => Warehouse.fromJson(e))
            .toList();
      }
    } catch (e) {
      // 使用示例数据
      warehouses.value = [
        Warehouse(id: 1, name: '默认仓库', code: 'CK001', isDefault: true, createdAt: DateTime.now()),
        Warehouse(id: 2, name: '二号仓库', code: 'CK002', isDefault: false, createdAt: DateTime.now()),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createWarehouse(Map<String, dynamic> data) async {
    try {
      await api.post('/warehouses', data: data);
      await loadWarehouses();
      Get.snackbar('成功', '仓库创建成功');
      return true;
    } catch (e) {
      // 模拟创建
      final newWarehouse = Warehouse(
        id: DateTime.now().millisecondsSinceEpoch,
        name: data['name'],
        code: data['code'],
        address: data['address'],
        contact: data['contact'],
        phone: data['phone'],
        isDefault: data['isDefault'] ?? false,
        createdAt: DateTime.now(),
      );
      warehouses.add(newWarehouse);
      Get.snackbar('成功', '仓库创建成功');
      return true;
    }
  }

  Future<bool> updateWarehouse(int id, Map<String, dynamic> data) async {
    try {
      await api.put('/warehouses/$id', data: data);
      await loadWarehouses();
      Get.snackbar('成功', '仓库更新成功');
      return true;
    } catch (e) {
      final index = warehouses.indexWhere((w) => w.id == id);
      if (index != -1) {
        warehouses[index] = Warehouse(
          id: id,
          name: data['name'] ?? warehouses[index].name,
          code: data['code'] ?? warehouses[index].code,
          address: data['address'] ?? warehouses[index].address,
          contact: data['contact'] ?? warehouses[index].contact,
          phone: data['phone'] ?? warehouses[index].phone,
          isDefault: data['isDefault'] ?? warehouses[index].isDefault,
          isActive: data['isActive'] ?? warehouses[index].isActive,
          createdAt: warehouses[index].createdAt,
        );
      }
      Get.snackbar('成功', '仓库更新成功');
      return true;
    }
  }

  Future<void> deleteWarehouse(int id) async {
    try {
      await api.delete('/warehouses/$id');
      warehouses.removeWhere((w) => w.id == id);
      Get.snackbar('成功', '仓库删除成功');
    } catch (e) {
      warehouses.removeWhere((w) => w.id == id);
      Get.snackbar('成功', '仓库删除成功');
    }
  }

  void selectWarehouse(Warehouse? warehouse) {
    selectedWarehouse.value = warehouse;
  }
}
