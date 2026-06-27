import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../../../data/models/order_model.dart';

class OrderDetailView extends GetView<OrderController> {
  const OrderDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as Order;
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情'),
        backgroundColor: const Color(0xFF2fc27d),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(order),
            const SizedBox(height: 16),
            _buildInfoCard(order),
            const SizedBox(height: 16),
            _buildItemsCard(order),
            const SizedBox(height: 16),
            _buildAmountCard(order),
            if (order.remark != null) ...[
              const SizedBox(height: 16),
              _buildRemarkCard(order),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(order),
    );
  }

  Widget _buildBottomBar(Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 打印按钮行
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/print/preview', arguments: {
                      'templateType': 'receipt',
                      'orderId': order.id,
                    }),
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('打印小票'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 将订单商品转换为条码打印格式
                      final products = order.items.map((item) => {
                        'barcode': item.barcode ?? '',
                        'name': item.productName,
                        'salePrice': item.unitPrice,
                      }).where((p) => (p['barcode'] as String).isNotEmpty).toList();
                      
                      if (products.isNotEmpty) {
                        Get.toNamed('/barcode/print', arguments: {
                          'products': products,
                        });
                      } else {
                        Get.snackbar('提示', '订单中没有可打印条码的商品');
                      }
                    },
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('打印条码'),
                  ),
                ),
              ],
            ),
            if (order.status == 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.cancelOrder(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('取消订单'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.completeOrder(order.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2fc27d),
                      ),
                      child: const Text('完成订单'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Order order) {
    final colors = {
      0: Colors.orange,
      1: Colors.blue,
      2: Colors.green,
      3: Colors.red,
    };
    final labels = {
      0: '待处理',
      1: '已确认',
      2: '已完成',
      3: '已取消',
    };
    return Card(
      color: colors[order.status]?.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.info, color: colors[order.status]),
        title: Text(
          '订单状态: ${labels[order.status] ?? '未知'}',
          style: TextStyle(color: colors[order.status], fontWeight: FontWeight.bold),
        ),
        subtitle: Text('订单号: ${order.orderNo}'),
      ),
    );
  }

  Widget _buildInfoCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基本信息', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('客户', order.customerName),
            _buildInfoRow('下单时间', '${order.createTime.year}-${order.createTime.month.toString().padLeft(2, '0')}-${order.createTime.day.toString().padLeft(2, '0')}'),
            if (order.remark != null)
              _buildInfoRow('备注', order.remark!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Order order) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('商品明细', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...order.items.map((item) => ListTile(
            title: Row(
              children: [
                Expanded(child: Text(item.displayName)),
                if (item.isMultiSku)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('SKU', style: TextStyle(fontSize: 10, color: Color(0xFF1976D2))),
                  ),
                if (item.isMultiUnit)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('多单位', style: TextStyle(fontSize: 10, color: Color(0xFF7B1FA2))),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¥${item.unitPrice.toStringAsFixed(2)} x ${item.quantity} ${item.unit}'),
                if (item.isMultiUnit && item.actualQuantity != null)
                  Text('等于 ${item.actualQuantity} 件（基础单位）', 
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            trailing: Text('¥${item.amount.toStringAsFixed(2)}'),
          )),
        ],
      ),
    );
  }

  Widget _buildAmountCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAmountRow('商品总额', order.totalAmount + order.discountAmount),
            if (order.discountAmount > 0)
              _buildAmountRow('优惠金额', -order.discountAmount),
            const Divider(),
            _buildAmountRow('实付金额', order.totalAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF2fc27d) : null,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkCard(Order order) {
    return Card(
      child: ListTile(
        title: const Text('备注'),
        subtitle: Text(order.remark!),
      ),
    );
  }
}
