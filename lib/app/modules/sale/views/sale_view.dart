import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/sale_controller.dart';

class SaleView extends GetView<SaleController> {
  const SaleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickActions(),
          Expanded(
            child: _buildSaleList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2FC27D),
        onPressed: controller.createSale,
        child: const Icon(Icons.add, color: Colors.white),
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
          const TDText('销售管理',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Row(
            children: [
              TDButton(
                text: '销售统计',
                theme: TDButtonTheme.light,
                size: TDButtonSize.small,
                onTap: controller.viewStatistics,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(Icons.point_of_sale, '开单', controller.createSale),
          _buildActionItem(Icons.history, '历史', controller.viewHistory),
          _buildActionItem(Icons.people, '客户', controller.manageCustomers),
          _buildActionItem(Icons.local_offer, '促销', controller.managePromotions),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7EF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2FC27D), size: 24),
          ),
          const SizedBox(height: 8),
          TDText(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSaleList() {
    return Obx(() => controller.sales.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.sales.length,
            itemBuilder: (context, index) {
              final sale = controller.sales[index];
              return _buildSaleCard(sale);
            },
          ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          TDText('暂无销售记录', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 8),
          TDButton(
            text: '去开单',
            theme: TDButtonTheme.primary,
            onTap: controller.createSale,
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(dynamic sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TDText('单号: ${sale['orderNo'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildStatusTag(sale['status'] ?? 'pending'),
            ],
          ),
          const SizedBox(height: 8),
          TDText('客户: ${sale['customer'] ?? '散客'}',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          TDText('金额: ¥${sale['amount'] ?? 0}',
              style: const TextStyle(
                  color: Color(0xFF2FC27D), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    final statusMap = {
      'pending': {'text': '待付款', 'color': Colors.orange},
      'paid': {'text': '已付款', 'color': const Color(0xFF2FC27D)},
      'cancelled': {'text': '已取消', 'color': Colors.grey},
    };
    final statusInfo = statusMap[status] ?? {'text': '未知', 'color': Colors.grey};
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (statusInfo['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TDText(
        statusInfo['text'] as String,
        style: TextStyle(
          color: statusInfo['color'] as Color,
          fontSize: 12,
        ),
      ),
    );
  }
}
