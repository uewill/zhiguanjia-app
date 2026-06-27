import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/quick_actions.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            const SliverToBoxAdapter(
              child: QuickSearchBar(
                hintText: '搜索商品、客户、订单...',
              ),
            ),
            const SliverToBoxAdapter(child: QuickActionsGrid()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatCards(),
                    const SizedBox(height: 16),
                    _buildChartAndAlert(),
                    const SizedBox(height: 16),
                    _buildBottomSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const FloatingQuickActions(),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF2FC27D),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TDText(
              '仪表板',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Stack(
                children: [
                  const TDText('🔔', style: TextStyle(fontSize: 24)),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Obx(() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '今日销售',
                '¥${controller.todayRevenue.value.toStringAsFixed(0)}',
                '+12.5%',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '今日采购',
                '¥2,800',
                '-5.2%',
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '库存总值',
                '¥125,000',
                '+8.3%',
                const Color(0xFF2FC27D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '营业额',
                '${controller.todayOrders.value}单',
                '+3',
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, String change, Color color) {
    final isPositive = !change.startsWith('-');
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
          TDText(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF86909C),
            ),
          ),
          const SizedBox(height: 8),
          TDText(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          TDText(
            change,
            style: TextStyle(
              fontSize: 12,
              color: isPositive ? const Color(0xFF00B42A) : const Color(0xFFF53F3F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndAlert() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildSalesChart(),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildInventoryAlert(),
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
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
          const TDText(
            '销售趋势',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2129),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
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
                        const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                        if (value >= 0 && value < days.length) {
                          return TDText(
                            days[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF86909C),
                            ),
                          );
                        }
                        return const TDText('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1200),
                      FlSpot(1, 1800),
                      FlSpot(2, 1500),
                      FlSpot(3, 2200),
                      FlSpot(4, 1900),
                      FlSpot(5, 2500),
                      FlSpot(6, 2800),
                    ],
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
    );
  }

  Widget _buildInventoryAlert() {
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
          const TDText(
            '库存预警',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2129),
            ),
          ),
          const SizedBox(height: 12),
          _buildAlertItem('可乐', '< 10', const Color(0xFFFF7D00)),
          _buildAlertItem('红牛', '< 5', const Color(0xFFFF7D00)),
          _buildAlertItem('泡面', '临期', const Color(0xFFF53F3F)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.toNamed('/warning/list'),
            child: const TDText(
              '查看全部 →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2FC27D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String name, String alert, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          TDText('⚠️', style: TextStyle(color: color)),
          const SizedBox(width: 6),
          Expanded(
            child: TDText(
              name,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TDText(
            alert,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildQuickEntry(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTodoList(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRecentActivity(),
        ),
      ],
    );
  }

  Widget _buildQuickEntry() {
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
          const TDText(
            '快捷入口',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2129),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickItem(Icons.add_shopping_cart, '新建订单', () => Get.toNamed('/order/create')),
          _buildQuickItem(Icons.add_box, '添加商品', () => Get.toNamed('/product/form')),
          _buildQuickItem(Icons.inventory, '库存查询', () => Get.toNamed('/inventory')),
          _buildQuickItem(Icons.people, '职员管理', () => Get.toNamed('/staff/list')),
          _buildQuickItem(Icons.security, '权限设置', () => Get.toNamed('/permission/list')),
          _buildQuickItem(Icons.warning_amber, '库存预警', () => Get.toNamed('/warning/list')),
          _buildQuickItem(Icons.bar_chart, '经营报表', () => Get.toNamed('/report/finance')),
          _buildQuickItem(Icons.backup, '数据备份', () => Get.toNamed('/backup')),
          _buildQuickItem(Icons.print, '打印设置', () => Get.toNamed('/print/settings')),
          // P0 差异功能入口
          _buildQuickItem(Icons.warehouse, '仓库管理', () => Get.toNamed('/warehouse/list')),
          _buildQuickItem(Icons.inventory, '库存盘点', () => Get.toNamed('/stock-check/list')),
          _buildQuickItem(Icons.transfer_within_a_station, '调拨管理', () => Get.toNamed('/transfer/list')),
          _buildQuickItem(Icons.shopping_cart, '采购订单', () => Get.toNamed('/purchase-order/list')),
          _buildQuickItem(Icons.receipt_long, '销售订单', () => Get.toNamed('/sale-order/list')),
          _buildQuickItem(Icons.mic, '智能开单', () => Get.toNamed('/sale-order/smart')),
          _buildQuickItem(Icons.upload_file, '批量导入导出', () => Get.toNamed('/excel/import-export')),
        ],
      ),
    );
  }

  Widget _buildQuickItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2FC27D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2FC27D), size: 20),
            ),
            const SizedBox(width: 10),
            TDText(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1D2129),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList() {
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
          const TDText(
            '待办事项',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2129),
            ),
          ),
          const SizedBox(height: 12),
          _buildTodoItem('• 3笔待审核', const Color(0xFFFF7D00)),
          _buildTodoItem('• 5笔待入库', const Color(0xFF2FC27D)),
          _buildTodoItem('• 2笔待付款', const Color(0xFFF53F3F)),
        ],
      ),
    );
  }

  Widget _buildTodoItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TDText(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
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
          const TDText(
            '最近动态',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2129),
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem('销售单123', '已完成'),
          _buildActivityItem('采购卑45', '待入库'),
          _buildActivityItem('调拨卑1', '已审核'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TDText(
              title,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: status == '已完成'
                  ? const Color(0xFFE8F5E9)
                  : status == '待入库'
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TDText(
              status,
              style: TextStyle(
                fontSize: 11,
                color: status == '已完成'
                    ? const Color(0xFF00B42A)
                    : status == '待入库'
                        ? const Color(0xFFFF7D00)
                        : const Color(0xFF2FC27D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
