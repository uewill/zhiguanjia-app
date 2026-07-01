import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/workflow_controller.dart';
import '../../../data/models/workflow_model.dart';

/// 单据状态历史页面
class StatusHistoryView extends GetView<WorkflowController> {
  const StatusHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final orderId = args['orderId'] ?? 0;
    final orderType = args['orderType'] ?? 'sale';

    // 加载历史记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadStatusHistory(orderId, orderType);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '状态历史',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 单据信息卡片
          _buildOrderInfoCard(orderId, orderType),
          // 时间线
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.statusHistory.isEmpty) {
                return _buildEmptyState();
              }
              return _buildTimeline();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(int orderId, String orderType) {
    final typeNames = {
      'sale': '销售单',
      'purchase': '采购单',
      'transfer': '调拨单',
    };

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF2FC27D),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeNames[orderType] ?? '单据',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '单号: $orderId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无状态变更记录',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.statusHistory.length,
      itemBuilder: (context, index) {
        final history = controller.statusHistory[index];
        final isLast = index == controller.statusHistory.length - 1;
        return _buildTimelineItem(history, isLast);
      },
    );
  }

  Widget _buildTimelineItem(StatusHistory history, bool isLast) {
    final fromStatusName = OrderStatus.getName(history.fromStatus);
    final toStatusName = OrderStatus.getName(history.toStatus);
    final statusColor = Color(OrderStatus.getColor(history.toStatus));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // 内容
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$fromStatusName → $toStatusName',
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(history.createTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        history.operatorName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  if (history.reason != null && history.reason!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              history.reason!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}-${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
