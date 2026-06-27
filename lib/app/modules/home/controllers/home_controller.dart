import 'package:get/get.dart';
import '../../../services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var todaySales = 0.0.obs;
  var todayRevenue = 0.0.obs;
  var todayOrders = 0.obs;
  var todayProfit = 0.0.obs;
  var todayCustomers = 0.obs;
  var totalProducts = 0.obs;
  var totalCustomers = 0.obs;
  var lowStockCount = 0.obs;
  var isLoading = false.obs;
  var currentIndex = 0.obs;
  
  var lowStockProducts = <dynamic>[].obs;
  var recentOrders = <dynamic>[].obs;
  var hotProducts = <dynamic>[].obs;

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        break;
      case 1:
        Get.toNamed('/inventory');
        break;
      case 2:
        Get.toNamed('/purchase/create');
        break;
      case 3:
        Get.toNamed('/finance');
        break;
      case 4:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    todayRevenue.bindStream(todaySales.stream);
    loadDashboardData();
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/dashboard');
      if (response.data['code'] == 200) {
        final data = response.data['data'];
        todaySales.value = (data['todaySales'] as num).toDouble();
        todayOrders.value = data['todayOrders'];
        todayProfit.value = (data['todayProfit'] as num).toDouble();
        todayCustomers.value = data['todayCustomers'];
        totalProducts.value = data['totalProducts'];
        totalCustomers.value = data['totalCustomers'];
        lowStockCount.value = data['lowStockCount'];
      }
    } catch (e) {
      Get.snackbar('错误', '加载数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
