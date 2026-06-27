import 'package:get/get.dart';
import '../contracts/order_contracts.dart';
import '../utils/logger.dart';
import '../../services/api_service.dart';

/// 抽象单据控制器 - 模板方法模式
/// 子类只需实现特定方法，通用逻辑在此处统一处理
abstract class BaseOrderController<T extends IOrder, I extends IOrderItem>
    extends GetxController {
  
  final ApiService api;
  
  BaseOrderController({required this.api});

  // ========== 抽象方法 - 子类必须实现 ==========
  
  /// 单据类型
  OrderType get orderType;
  
  /// API基础路径
  String get apiBasePath;
  
  /// 从JSON解析单据对象
  T parseOrder(dynamic json);
  
  /// 从JSON解析明细对象
  I parseItem(dynamic json);
  
  /// 创建单据数据
  Map<String, dynamic> buildOrderData();
  
  /// 验证单据数据
  ValidationResult validateOrder();
  
  /// 获取单号前缀
  String get orderNoPrefix => orderType.prefix;

  // ========== 通用状态 ==========
  
  final orders = <T>[].obs;
  final isLoading = false.obs;
  final currentOrder = Rxn<T>();
  
  // 创建单据用通用状态
  final orderItems = <I>[].obs;
  final remark = ''.obs;
  final businessDate = DateTime.now().obs;
  final expectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // ========== 模板方法 - 通用逻辑 ==========
  
  /// 加载单据列表 - 模板方法
  Future<void> loadOrders() async {
    await executeWithLoading(() async {
      try {
        final response = await api.get('$apiBasePath');
        if (response.data != null && response.data['data'] != null) {
          orders.value = (response.data['data'] as List)
              .map((e) => parseOrder(e))
              .toList();
        }
      } catch (e) {
        Logger.w('加载${orderType.label}列表失败，使用模拟数据', error: e);
        orders.value = generateMockData();
      }
    });
  }

  /// 创建单据 - 模板方法
  Future<bool> createOrder() async {
    // 步骤1: 验证
    final validation = validateOrder();
    if (!validation.isValid) {
      Get.snackbar('验证失败', validation.errorMessage ?? '请检查输入');
      return false;
    }
    
    // 步骤2: 构建数据
    final data = buildOrderData();
    
    // 步骤3: 提交
    final result = await executeWithLoading(() async {
      try {
        final response = await api.post(apiBasePath, data: data);
        if (response.data != null && response.data['data'] != null) {
          final newOrder = parseOrder(response.data['data']);
          orders.insert(0, newOrder);
          clearForm();
          onOrderCreated(newOrder);
          return true;
        }
      } catch (e) {
        Logger.w('创建${orderType.label}失败，使用本地模拟', error: e);
        final mockOrder = createMockOrder();
        orders.insert(0, mockOrder);
        clearForm();
        return true;
      }
      return false;
    });
    return result ?? false;
  }

  /// 取消单据 - 模板方法
  Future<bool> cancelOrder(int orderId) async {
    final result = await executeWithLoading(() async {
      try {
        await api.post('$apiBasePath/$orderId/cancel');
        await loadOrders();
        Get.snackbar('成功', '${orderType.label}已取消');
        return true;
      } catch (e) {
        Logger.w('取消${orderType.label}失败', error: e);
        updateOrderStatus(orderId, OrderStatus.cancelled);
        Get.snackbar('成功', '${orderType.label}已取消');
        return true;
      }
    });
    return result ?? false;
  }

  /// 完成单据 - 模板方法
  Future<bool> completeOrder(int orderId) async {
    final result = await executeWithLoading(() async {
      try {
        await api.post('$apiBasePath/$orderId/complete');
        await loadOrders();
        Get.snackbar('成功', '${orderType.label}已完成');
        return true;
      } catch (e) {
        Logger.w('完成${orderType.label}失败', error: e);
        updateOrderStatus(orderId, OrderStatus.completed);
        Get.snackbar('成功', '${orderType.label}已完成');
        return true;
      }
    });
    return result ?? false;
  }

  // ========== 明细操作 - 通用逻辑 ==========
  
  /// 添加明细项
  void addOrderItem(I item);
  
  /// 更新明细数量
  void updateItemQuantity(int index, double quantity) {
    if (index >= 0 && index < orderItems.length) {
      if (quantity <= 0) {
        orderItems.removeAt(index);
      } else {
        updateItemAt(index, quantity);
        orderItems.refresh();
      }
    }
  }
  
  /// 更新单个明细 - 子类实现
  void updateItemAt(int index, double quantity);
  
  /// 删除明细
  void removeItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      orderItems.removeAt(index);
    }
  }
  
  /// 清空表单
  void clearForm() {
    orderItems.clear();
    remark.value = '';
    businessDate.value = DateTime.now();
    expectedDate.value = null;
    clearSpecificFields();
  }
  
  /// 清空特定字段 - 子类实现
  void clearSpecificFields();

  // ========== 计算属性 ==========
  
  double get totalAmount => orderItems.fold(
      0, (sum, item) => sum + ((item.quantity * (item.price ?? 0))));

  int get totalQuantity => 
      orderItems.fold(0, (sum, item) => sum + item.quantity.toInt());

  // ========== 工具方法 ==========
  
  /// 带加载状态的执行
  Future<T?> executeWithLoading<T>(Future<T?> Function() action) async {
    isLoading.value = true;
    try {
      return await action();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 更新单据状态
  void updateOrderStatus(int orderId, OrderStatus status) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // 由于T是不可变的，需要子类提供更新方法
      updateOrderStatusAt(index, status);
      orders.refresh();
    }
  }
  
  /// 更新单据状态 - 子类实现
  void updateOrderStatusAt(int index, OrderStatus status);

  // ========== 回调方法 ==========
  
  /// 单据创建后回调
  void onOrderCreated(T order) {
    Get.snackbar('成功', '${orderType.label}创建成功');
  }

  // ========== 模拟数据 - 子类可覆盖 ==========
  
  List<T> generateMockData();
  T createMockOrder();
}
