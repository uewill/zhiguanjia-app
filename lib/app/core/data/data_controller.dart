import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import 'data_base.dart';

/// 资料类控制器基类 - 模板方法模式
abstract class DataController<T extends DataItem> extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // 子类必须实现的配置
  DataPageConfig get config;
  
  // 子类必须实现的数据转换
  T fromJson(Map<String, dynamic> json);
  
  // 状态
  final items = <T>[].obs;
  final filteredItems = <T>[].obs;
  final isLoading = false.obs;
  final searchKeyword = ''.obs;
  final currentFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 监听搜索关键词变化
    ever(searchKeyword, (_) => filterItems());
    ever(currentFilter, (_) => filterItems());
    loadData();
  }

  /// 加载数据 - 模板方法
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final data = await fetchDataFromApi();
      items.value = data;
      filterItems();
    } finally {
      isLoading.value = false;
    }
  }

  /// 从API获取数据 - 子类可覆盖
  Future<List<T>> fetchDataFromApi() async {
    try {
      final response = await _apiService.get(config.apiEndpoint);
      if (response.data['code'] == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => fromJson(e)).toList();
        } else if (data is Map && data['list'] is List) {
          return (data['list'] as List).map((e) => fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('加载数据失败: $e');
      // 如果API调用失败，返回模拟数据
      return getMockData();
    }
    return [];
  }

  /// 模拟数据 - 子类可覆盖
  List<T> getMockData() => [];

  /// 创建数据
  Future<bool> createData(Map<String, dynamic> data) async {
    try {
      await _apiService.post(config.apiEndpoint, data: data);
      await loadData();
      Get.snackbar('成功', '${config.singularName}创建成功');
      return true;
    } catch (e) {
      Get.snackbar('错误', '${config.singularName}创建失败: $e');
      return false;
    }
  }

  /// 更新数据
  Future<bool> updateData(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.put('${config.apiEndpoint}/$id', data: data);
      await loadData();
      Get.snackbar('成功', '${config.singularName}更新成功');
      return true;
    } catch (e) {
      Get.snackbar('错误', '${config.singularName}更新失败: $e');
      return false;
    }
  }

  /// 删除数据
  Future<bool> deleteData(int id) async {
    try {
      await _apiService.delete('${config.apiEndpoint}/$id');
      items.removeWhere((item) => item.id == id);
      filterItems();
      Get.snackbar('成功', '${config.singularName}已删除');
      return true;
    } catch (e) {
      Get.snackbar('错误', '${config.singularName}删除失败: $e');
      return false;
    }
  }

  /// 搜索数据
  void search(String keyword) {
    searchKeyword.value = keyword;
  }

  /// 筛选数据
  void filterItems() {
    var result = items.toList();
    
    // 文本搜索
    if (searchKeyword.value.isNotEmpty) {
      final keyword = searchKeyword.value.toLowerCase();
      result = result.where((item) {
        for (final field in config.searchFields) {
          final value = _getFieldValue(item, field);
          if (value.toString().toLowerCase().contains(keyword)) {
            return true;
          }
        }
        return false;
      }).toList();
    }
    
    // 分类筛选
    if (currentFilter.value.isNotEmpty) {
      result = result.where((item) {
        final category = _getFieldValue(item, 'categoryId') ?? _getFieldValue(item, 'category');
        return category.toString() == currentFilter.value;
      }).toList();
    }
    
    filteredItems.value = result;
  }

  /// 获取字段值
  dynamic _getFieldValue(T item, String field) {
    if (field == 'name') return item.name;
    if (field == 'code') return item.code;
    // 使用反射获取其他字段
    try {
      return (item as dynamic).toJson()[field];
    } catch (_) {
      return '';
    }
  }

  /// 刷新
  Future<void> refresh() => loadData();
}

/// 资料表单控制器基类
abstract class DataFormController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // 子类必须实现的配置
  DataPageConfig get config;
  
  // 编辑模式
  final isEditMode = false.obs;
  final editId = Rxn<int>();
  
  // 加载状态
  final isLoading = false.obs;
  
  // 通用字段
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final remarkController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // 检查是否是编辑模式
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args['id'] != null) {
        isEditMode.value = true;
        editId.value = args['id'] as int;
        loadDataForEdit();
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    phoneController.dispose();
    addressController.dispose();
    remarkController.dispose();
    super.onClose();
  }

  /// 加载编辑数据 - 子类可覆盖
  Future<void> loadDataForEdit() async {
    if (editId.value == null) return;
    isLoading.value = true;
    try {
      final response = await _apiService.get('${config.apiEndpoint}/${editId.value}');
      if (response.data['code'] == 200) {
        populateForm(response.data['data']);
      }
    } catch (e) {
      Get.snackbar('错误', '加载数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 填充表单 - 子类必须实现
  void populateForm(Map<String, dynamic> data);

  /// 验证表单 - 子类可覆盖
  bool validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('提示', '${config.singularName}名称不能为空');
      return false;
    }
    return true;
  }

  /// 收集表单数据 - 子类必须实现
  Map<String, dynamic> collectFormData();

  /// 提交表单
  Future<bool> submit() async {
    if (!validateForm()) return false;
    
    isLoading.value = true;
    try {
      final data = collectFormData();
      if (isEditMode.value) {
        await _apiService.put('${config.apiEndpoint}/${editId.value}', data: data);
      } else {
        await _apiService.post(config.apiEndpoint, data: data);
      }
      Get.snackbar('成功', isEditMode.value ? '修改成功' : '创建成功');
      return true;
    } catch (e) {
      Get.snackbar('错误', '保存失败: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
