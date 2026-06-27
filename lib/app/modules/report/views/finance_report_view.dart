import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/finance_report_controller.dart';

class FinanceReportView extends GetView<FinanceReportController> {
  const FinanceReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('经营报表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: controller.printReport,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.exportReport,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildReportHeader(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildTrendChart(),
              const SizedBox(height: 16),
              _buildPaymentChart(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'daily', label: Text('日报')),
                    ButtonSegment(value: 'weekly', label: Text('周报')),
                    ButtonSegment(value: 'monthly', label: Text('月报')),
                  ],
                  selected: {controller.reportType.value},
                  onSelectionChanged: (value) {
                    if (value.isNotEmpty) {
                      controller.onReportTypeChanged(value.first);
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: Get.context!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(
                      start: controller.startDate.value,
                      end: controller.endDate.value,
                    ),
                  );
                  if (picked != null) {
                    controller.onDateRangeChanged(picked.start, picked.end);
                  }
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  '${controller.startDate.value.toString().substring(0, 10)} 至 ${controller.endDate.value.toString().substring(0, 10)}',
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '销售额',
                '¥${controller.totalSales.value.toStringAsFixed(0)}',
                '+12.5%',
                Colors.green,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '采购额',
                '¥${controller.totalPurchases.value.toStringAsFixed(0)}',
                '+8.3%',
                Colors.orange,
                Icons.shopping_cart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '毛利润',
                '¥${controller.grossProfit.value.toStringAsFixed(0)}',
                '32.6%',
                Colors.blue,
                Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '订单数',
                '${controller.orderCount.value}',
                '+15单',
                Colors.purple,
                Icons.receipt_long,
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '环比 $subtitle',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '营收趋势',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: controller.salesTrend.isEmpty
              ? const Center(child: Text('暂无数据'))
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < controller.trendLabels.length) {
                              return Text(
                                controller.trendLabels[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.salesTrend,
                        isCurved: true,
                        color: const Color(0xFF2FC27D),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF2FC27D).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPaymentChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '支付方式分布',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: controller.totalSales.value * 0.4,
                    title: '现金',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: controller.totalSales.value * 0.35,
                    title: '微信',
                    color: Colors.blue,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: controller.totalSales.value * 0.25,
                    title: '支付宝',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
