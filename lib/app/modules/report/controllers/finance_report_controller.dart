import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class FinanceReportController extends GetxController {
  final RxString selectedPeriod = 'week'.obs;
  final RxString reportType = 'summary'.obs; // summary, detail, trend
  final RxBool isLoading = false.obs;
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Summary data
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxDouble grossProfit = 0.0.obs;
  final RxInt orderCount = 0.obs;

  // Chart data
  final RxList<FlSpot> salesTrend = <FlSpot>[].obs;
  final RxList<String> trendLabels = <String>[].obs;
  
  // Report data
  final RxMap<String, dynamic> report = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadReportData();
  }

  Future<void> loadReportData() async {
    isLoading.value = true;
    try {
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));

      totalSales.value = 52850.00;
      totalPurchases.value = 35620.00;
      grossProfit.value = 17230.00;
      orderCount.value = 156;

      // Generate mock trend data
      salesTrend.value = [
        const FlSpot(0, 5000),
        const FlSpot(1, 7500),
        const FlSpot(2, 6800),
        const FlSpot(3, 9200),
        const FlSpot(4, 8500),
        const FlSpot(5, 7800),
        const FlSpot(6, 8150),
      ];

      trendLabels.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      report.value = {
        'period': selectedPeriod.value,
        'sales': totalSales.value,
        'purchases': totalPurchases.value,
        'profit': grossProfit.value,
        'orders': orderCount.value,
      };
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadReportData();
  }
  
  void onReportTypeChanged(String type) {
    reportType.value = type;
    loadReportData();
  }
  
  void onDateRangeChanged(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    loadReportData();
  }

  void exportReport() {
    _showToast('导出功能开发中');
  }

  void printReport() {
    _showToast('打印功能开发中');
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }
}
