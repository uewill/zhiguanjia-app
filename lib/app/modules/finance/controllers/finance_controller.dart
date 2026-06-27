import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../services/api_service.dart';
import '../views/payment_view.dart';

class FinanceController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Tab 状态
  final selectedTab = 0.obs;
  final tabs = ['应收应付', '收付款', '财务流水', '营业报表'];
  
  // 加载状态
  final isLoading = false.obs;
  
  // 营业报表数据
  final revenueData = <FlSpot>[].obs;
  final selectedPeriod = 'week'.obs;
  final hotProducts = <Map<String, dynamic>>[].obs;
  
  // 应收应付数据
  final receivables = <Map<String, dynamic>>[].obs;
  final payables = <Map<String, dynamic>>[].obs;
  
  // 流水数据
  final journalList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateSampleData();
    _loadReceivablesPayables();
    _loadJournalData();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void _generateSampleData() {
    revenueData.value = [
      const FlSpot(0, 1200),
      const FlSpot(1, 1800),
      const FlSpot(2, 1500),
      const FlSpot(3, 2200),
      const FlSpot(4, 1900),
      const FlSpot(5, 2500),
      const FlSpot(6, 2800),
    ];
    
    hotProducts.value = [
      {'name': '可乐', 'quantity': 128, 'unit': '罐', 'revenue': 1280.0},
      {'name': '红牛', 'quantity': 96, 'unit': '罐', 'revenue': 960.0},
      {'name': '泡面', 'quantity': 85, 'unit': '袋', 'revenue': 425.0},
      {'name': '饭团', 'quantity': 72, 'unit': '个', 'revenue': 360.0},
      {'name': '水', 'quantity': 68, 'unit': '瓶', 'revenue': 204.0},
    ];
  }
  
  void _loadReceivablesPayables() {
    receivables.value = [
      {'name': '张三客户', 'amount': 12500.00, 'overdue': false},
      {'name': '李四客户', 'amount': 8300.00, 'overdue': true},
      {'name': '王五客户', 'amount': 5600.00, 'overdue': false},
    ];
    
    payables.value = [
      {'name': '可口可乐供应商', 'amount': 28000.00, 'overdue': false},
      {'name': '红牛供应商', 'amount': 15000.00, 'overdue': true},
      {'name': '泡面供应商', 'amount': 8200.00, 'overdue': false},
    ];
  }
  
  void _loadJournalData() {
    journalList.value = [
      {'date': '2024-01-15', 'type': '销售收入', 'in': 3500.00, 'out': 0.00},
      {'date': '2024-01-15', 'type': '采购支出', 'in': 0.00, 'out': 2800.00},
      {'date': '2024-01-14', 'type': '销售收入', 'in': 4200.00, 'out': 0.00},
      {'date': '2024-01-14', 'type': '库存盘盈', 'in': 500.00, 'out': 0.00},
      {'date': '2024-01-13', 'type': '运营支出', 'in': 0.00, 'out': 1200.00},
    ];
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    _generateSampleData();
  }
  
  void exportReport() {
    _showToast('导出功能开发中');
  }
  
  void showReceipt() {
    Get.to(() => const PaymentView());
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }
}
