import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/warehouse_controller.dart';
import 'warehouse_form_view.dart';

class WarehouseListView extends StatelessWidget {
  const WarehouseListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WarehouseController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '仓库管理',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        rightBarItems: [
          TDNavBarItem(
            icon: TDIcons.add,
            iconColor: Colors.white,
            action: () => Get.to(() => const WarehouseFormView()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.warehouses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const TDText('暂无仓库', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TDButton(
                  text: '创建仓库',
                  theme: TDButtonTheme.primary,
                  onTap: () => Get.to(() => const WarehouseFormView()),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.warehouses.length,
          itemBuilder: (context, index) {
            final warehouse = controller.warehouses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warehouse, color: Color(0xFF2FC27D)),
                ),
                title: Row(
                  children: [
                    Expanded(child: TDText(warehouse.name, style: TextStyle(fontWeight: FontWeight.bold))),
                    if (warehouse.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const TDText('默认', style: TextStyle(fontSize: 12, color: Color(0xFF2FC27D))),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (warehouse.code != null) TDText('编码: ${warehouse.code}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    if (warehouse.address != null) TDText(warehouse.address!, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(() => WarehouseFormView(warehouse: warehouse));
                    } else if (value == 'delete') {
                      _showDeleteConfirm(controller, warehouse);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirm(WarehouseController controller, warehouse) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除仓库 "${warehouse.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteWarehouse(warehouse.id);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
