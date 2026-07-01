import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/warning_model.dart';
import '../controllers/warning_controller.dart';

class WarningListView extends GetView<WarningController> {
  const WarningListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存预警'),
        actions: [
          Obx(() => Badge(
            label: Text(controller.unreadCount.value.toString()),
            isLabelVisible: controller.unreadCount.value > 0,
            child: IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: controller.markAllAsRead,
            ),
          )),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.goToSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButton<int>(
                    value: controller.selectedType.value,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('全部预警')),
                      const DropdownMenuItem(value: 1, child: Text('库存不足')),
                      const DropdownMenuItem(value: 2, child: Text('库存积压')),
                      const DropdownMenuItem(value: 3, child: Text('临期预警')),
                      const DropdownMenuItem(value: 4, child: Text('滞销预警')),
                    ],
                    onChanged: controller.onTypeChanged,
                  )),
                ),
                const SizedBox(width: 16),
                Obx(() => FilterChip(
                  label: const Text('显示已读'),
                  selected: controller.showRead.value,
                  onSelected: (_) => controller.toggleShowRead(),
                )),
              ],
            ),
          ),
          // 预警列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredWarnings.isEmpty) {
                return const Center(child: Text('暂无预警'));
              }
              return ListView.builder(
                itemCount: controller.filteredWarnings.length,
                itemBuilder: (context, index) {
                  final warning = controller.filteredWarnings[index];
                  return _buildWarningCard(warning);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(InventoryWarning warning) {
    final color = Color(WarningType.getColor(warning.warningType));
    
    return Dismissible(
      key: Key(warning.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          controller.markAsRead(warning.id);
        } else {
          controller.deleteWarning(warning.id);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: warning.isRead ? Colors.grey[50] : null,
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getWarningIcon(warning.warningType),
              color: color,
            ),
          ),
          title: Row(
            children: [
              Expanded(child: Text(warning.productName)),
              if (!warning.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(warning.warningTypeName),
              Text(
                '当前: ${warning.currentStock} | 阈值: ${warning.thresholdValue}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (warning.warehouseName != null)
                Text(
                  warning.warehouseName!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          trailing: Text(
            _formatTime(warning.createTime),
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () => controller.goToRelatedItem(warning),
        ),
      ),
    );
  }

  IconData _getWarningIcon(int type) {
    switch (type) {
      case WarningType.lowStock:
        return Icons.trending_down;
      case WarningType.highStock:
        return Icons.trending_up;
      case WarningType.expiry:
        return Icons.timer;
      case WarningType.stagnant:
        return Icons.inventory_2;
      default:
        return Icons.warning;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }
}
