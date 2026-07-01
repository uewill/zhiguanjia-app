import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/finance_controller.dart';

class FinanceView extends GetView<FinanceController> {
  const FinanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: Obx(() => IndexedStack(
              index: controller.selectedTab.value,
              children: [
                _buildReceivablesPayablesTab(),
                _buildPaymentTab(),
                _buildJournalTab(),
                _buildReportTab(),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF2FC27D)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TDText('财务管理',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            TDButton(
            text: '收款',
            theme: TDButtonTheme.light,
            size: TDButtonSize.small,
            onTap: () {
              if (Get.context != null) {
                TDToast.showText('收款功能开发中', context: Get.context!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            controller.tabs.length,
            (index) => GestureDetector(
              onTap: () => controller.changeTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: controller.selectedTab.value == index
                          ? const Color(0xFF2FC27D)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: TDText(
                  controller.tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: controller.selectedTab.value == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: controller.selectedTab.value == index
                        ? const Color(0xFF2FC27D)
                        : const Color(0xFF86909C),
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  // 应收应付 Tab
  Widget _buildReceivablesPayablesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReceivablesCard(),
          const SizedBox(height: 16),
          _buildPayablesCard(),
        ],
      ),
    );
  }

  Widget _buildReceivablesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TDText('应收账款',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2129))),
              TDText('¥26,400.00',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
                children: controller.receivables
                    .map((item) => _buildReceivableItem(item))
                    .toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildPayablesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TDText('应付账款',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2129))),
              TDText('¥51,200.00',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
                children: controller.payables
                    .map((item) => _buildPayableItem(item))
                    .toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildReceivableItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                TDText(item['name'], style: const TextStyle(fontSize: 14)),
                if (item['overdue'])
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF53F3F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const TDText('逾期',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFFF53F3F))),
                  ),
              ],
            ),
          ),
          TDText('¥${(item['amount'] as double).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2FC27D))),
        ],
      ),
    );
  }

  Widget _buildPayableItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                TDText(item['name'], style: const TextStyle(fontSize: 14)),
                if (item['overdue'])
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF53F3F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const TDText('逾期',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFFF53F3F))),
                  ),
              ],
            ),
          ),
          TDText('¥${(item['amount'] as double).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7D00))),
        ],
      ),
    );
  }

  // 收付款 Tab
  Widget _buildPaymentTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          TDButton(
            text: '新建收付款单',
            theme: TDButtonTheme.primary,
            onTap: controller.showReceipt,
          ),
        ],
      ),
    );
  }

  // 财务流水 Tab
  Widget _buildJournalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TDText('财务流水',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2129))),
                TDButton(
                  text: '导出报表',
                  theme: TDButtonTheme.light,
                  size: TDButtonSize.small,
                  onTap: controller.exportReport,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: controller.journalList
                      .map((item) => _buildJournalItem(item))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalItem(Map<String, dynamic> item) {
    final isIncome = (item['in'] as double) > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(item['type'],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                TDText(item['date'],
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
              ],
            ),
          ),
          TDText(
            isIncome
                ? '+¥${(item['in'] as double).toStringAsFixed(2)}'
                : '-¥${(item['out'] as double).toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isIncome
                    ? const Color(0xFF00B42A)
                    : const Color(0xFFF53F3F)),
          ),
        ],
      ),
    );
  }

  // 营业报表 Tab
  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildSummaryCards(),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 16),
          _buildTopProducts(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => Row(
            children: [
              _buildPeriodButton('今日', 'day'),
              _buildPeriodButton('本周', 'week'),
              _buildPeriodButton('本月', 'month'),
              _buildPeriodButton('本年', 'year'),
            ],
          )),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = controller.selectedPeriod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2FC27D) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TDText(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
            child: _buildSummaryCard(
                '销售收入', '¥85,000.00', '+15%', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSummaryCard(
                '采购支出', '¥62,000.00', '+8%', Colors.orange)),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TDText(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TDText(amount,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('营收趋势',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1D2129))),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() => LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                            if (value >= 0 && value < days.length) {
                              return TDText(days[value.toInt()],
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const TDText('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.revenueData,
                        isCurved: true,
                        color: const Color(0xFF2FC27D),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('热销商品排行',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1D2129))),
          const SizedBox(height: 16),
          Obx(() => Column(
                children: controller.hotProducts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  final colors = [
                    Colors.amber,
                    Colors.grey.shade400,
                    Colors.brown.shade300,
                    Colors.grey.shade300,
                    Colors.grey.shade300
                  ];
                  return _buildProductItem(
                    '${index + 1}',
                    product['name'] ?? '-',
                    '${product['quantity'] ?? 0}${product['unit'] ?? '件'}',
                    '¥${product['revenue']?.toStringAsFixed(0) ?? 0}',
                    colors[index],
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildProductItem(
      String rank, String name, String quantity, String amount, Color rankColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: TDText(rank,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: TDText(name)),
          TDText(quantity, style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 12),
          TDText(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF2FC27D))),
        ],
      ),
    );
  }
}
