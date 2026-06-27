import 'package:get/get.dart';

class SaleController extends GetxController {
  final sales = <Map<String, dynamic>>[].obs;
  final selectedTab = 0.obs;
  final tabs = ['销售单', '退货单', '草稿箱'];

  @override
  void onInit() {
    super.onInit();
    loadSales();
  }

  void loadSales() {
    // 模拟加载销售数据
    sales.value = [];
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void createSale() {
    // 导航到开单页面
    Get.toNamed('/sale/create');
  }

  void viewHistory() {
    // 查看历史记录
  }

  void manageCustomers() {
    Get.toNamed('/customer');
  }

  void managePromotions() {
    // 管理促销活动
  }

  void viewStatistics() {
    Get.toNamed('/report/sale');
  }

  void viewSaleDetail(String id) {
    Get.toNamed('/sale/detail', parameters: {'id': id});
  }

  void cancelSale(String id) {
    // 取消销售单
  }

  void printSale(String id) {
    // 打印销售单
  }
}
