import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/workflow_controller.dart';
import '../../../data/models/workflow_model.dart';

/// 待审批列表页面
class ApprovalView extends GetView<WorkflowController> {
  const ApprovalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 加载待审批列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPendingApprovals('manager');
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '待审批',
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.pendingApprovals.isEmpty) {
          return _buildEmptyState();
        }
        return _buildApprovalList();
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无待审批单据',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '所有单据都已处理完毕',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.pendingApprovals.length,
      itemBuilder: (context, index) {
        final item = controller.pendingApprovals[index];
        return _buildApprovalCard(item);
      },
    );
  }

  Widget _buildApprovalCard(dynamic item) {
    final orderType = item['orderType'] ?? 'sale';
    final orderId = item['orderId'] ?? 0;
    final amount = item['amount'] ?? 0.0;
    final partnerName = item['partnerName'] ?? '';
    final createTime = item['createTime'] ?? '';

    final typeNames = {
      'sale': '销售单',
      'purchase': '采购单',
      'transfer': '调拨单',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '待审批',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF9500),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  typeNames[orderType] ?? '单据',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 详情
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '单号: $orderId',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      partnerName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '金额: ¥${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4D4F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      createTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          // 操作按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TDButton(
                    theme: TDButtonTheme.danger,
                    size: TDButtonSize.small,
                    type: TDButtonType.outline,
                    text: '驳回',
                    onTap: () => _onReject(orderId, orderType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TDButton(
                    theme: TDButtonTheme.primary,
                    size: TDButtonSize.small,
                    text: '通过',
                    onTap: () => _onApprove(orderId, orderType),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onApprove(int orderId, String orderType) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认审批'),
        content: const Text('确定要通过该单据吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.approveOrder(
                orderId: orderId,
                orderType: orderType,
                approved: true,
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _onReject(int orderId, String orderType) {
    controller.approveOrder(
      orderId: orderId,
      orderType: orderType,
      approved: false,
    );
  }
}
