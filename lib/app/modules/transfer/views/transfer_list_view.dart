import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/transfer_controller.dart';
import 'transfer_create_view.dart';

class TransferListView extends StatelessWidget {
  const TransferListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransferController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '调拨单',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        rightBarItems: [
          TDNavBarItem(icon: TDIcons.add, iconColor: Colors.white, action: () => Get.to(() => const TransferCreateView())),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transfers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const TDText('暂无调拨单', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TDButton(
                  text: '新建调拨单',
                  theme: TDButtonTheme.primary,
                  onTap: () => Get.to(() => const TransferCreateView()),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTransfers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.transfers.length,
            itemBuilder: (context, index) {
              final transfer = controller.transfers[index];
              return _buildTransferCard(controller, transfer);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2FC27D),
        onPressed: () => Get.to(() => const TransferCreateView()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransferCard(TransferController controller, dynamic transfer) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (transfer.status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = '已完成';
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = '已取消';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = '待确认';
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TDText(transfer.orderNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      TDText(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 调拨信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TDText('调出仓库', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TDText(transfer.fromWarehouseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Color(0xFF2FC27D)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const TDText('调入仓库', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TDText(transfer.toWarehouseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TDText('${transfer.itemCount}种商品', style: const TextStyle(color: Colors.grey)),
                    TDText('¥${transfer.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2FC27D))),
                  ],
                ),
                if (transfer.remark != null && transfer.remark!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TDText('备注: ${transfer.remark}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
                const SizedBox(height: 8),
                TDText(_formatDate(transfer.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          // 操作按钮
          if (transfer.status == 'pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TDButton(
                      text: '取消',
                      theme: TDButtonTheme.light,
                      size: TDButtonSize.small,
                      onTap: () => _showCancelDialog(controller, transfer.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TDButton(
                      text: '确认调拨',
                      theme: TDButtonTheme.primary,
                      size: TDButtonSize.small,
                      onTap: () => _showConfirmDialog(controller, transfer.id),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showConfirmDialog(TransferController controller, int transferId) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认调拨'),
        content: const Text('确认后将执行仓库调拨，确认吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.confirmTransfer(transferId);
            },
            child: const Text('确认', style: TextStyle(color: Color(0xFF2FC27D))),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(TransferController controller, int transferId) {
    Get.dialog(
      AlertDialog(
        title: const Text('取消调拨单'),
        content: const Text('确定要取消此调拨单吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('不取消')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.cancelTransfer(transferId);
            },
            child: const Text('取消', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
