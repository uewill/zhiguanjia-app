import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/stock_check_controller.dart';
import 'stock_check_create_view.dart';

class StockCheckListView extends StatelessWidget {
  const StockCheckListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockCheckController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '库存盘点',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        rightBarItems: [
          TDNavBarItem(
            icon: TDIcons.add,
            iconColor: Colors.white,
            action: () => Get.to(() => const StockCheckCreateView()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.stockChecks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const TDText('暂无盘点单', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TDButton(
                  text: '新建盘点',
                  theme: TDButtonTheme.primary,
                  onTap: () => Get.to(() => const StockCheckCreateView()),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.stockChecks.length,
          itemBuilder: (context, index) {
            final check = controller.stockChecks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                      TDText(check.orderNo, style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildStatusTag(check.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TDText('仓库: ${check.warehouseName}', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TDText('盘点数: ${check.itemCount}', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      if (check.profitCount != null && check.profitCount! > 0)
                        TDText('盈: +${check.profitCount}', style: TextStyle(fontSize: 12, color: Colors.green)),
                      const SizedBox(width: 16),
                      if (check.lossCount != null && check.lossCount! > 0)
                        TDText('亏: -${check.lossCount}', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TDText('${check.createdAt.month}/${check.createdAt.day} ${check.createdAt.hour}:${check.createdAt.minute}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String text;
    switch (status) {
      case 'completed':
        color = Colors.green;
        text = '已完成';
        break;
      case 'checking':
        color = Colors.orange;
        text = '盘点中';
        break;
      default:
        color = Colors.grey;
        text = '待盘点';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TDText(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
