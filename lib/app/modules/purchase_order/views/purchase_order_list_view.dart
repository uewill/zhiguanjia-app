import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/purchase_order_controller.dart';
import 'purchase_order_create_view.dart';

class PurchaseOrderListView extends StatelessWidget {
  const PurchaseOrderListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PurchaseOrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '采购订单',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        rightBarItems: [
          TDNavBarItem(icon: TDIcons.add, iconColor: Colors.white, action: () => Get.to(() => const PurchaseOrderCreateView())),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const TDText('暂无采购订单', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TDButton(
                  text: '新建采购订单',
                  theme: TDButtonTheme.primary,
                  onTap: () => Get.to(() => const PurchaseOrderCreateView()),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(controller, order);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2FC27D),
        onPressed: () => Get.to(() => const PurchaseOrderCreateView()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOrderCard(PurchaseOrderController controller, dynamic order) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
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
        statusText = '待入库';
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
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
                TDText(order.orderNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
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
          // 订单信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    TDText(order.supplierName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warehouse, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    TDText('入库仓库: ${order.warehouseName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TDText('${order.itemCount}种商品', style: const TextStyle(color: Colors.grey)),
                    TDText('¥${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2FC27D), fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                TDText('订单日期: ${_formatDate(order.orderDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          // 操作按钮
          if (order.status == 'pending')
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
                      onTap: () => _showCancelDialog(controller, order.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TDButton(
                      text: '转采购入库',
                      theme: TDButtonTheme.primary,
                      size: TDButtonSize.small,
                      onTap: () => _showConvertDialog(controller, order.id),
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showConvertDialog(PurchaseOrderController controller, int orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('转采购入库'),
        content: const Text('确认后将根据此订单生成采购入库单，确认吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.convertToPurchase(orderId);
            },
            child: const Text('确认', style: TextStyle(color: Color(0xFF2FC27D))),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(PurchaseOrderController controller, int orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('取消订单'),
        content: const Text('确定要取消此采购订单吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('不取消')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.cancelOrder(orderId);
            },
            child: const Text('取消', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
