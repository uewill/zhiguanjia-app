import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/transfer_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';

class TransferCreateView extends StatefulWidget {
  const TransferCreateView({Key? key}) : super(key: key);

  @override
  State<TransferCreateView> createState() => _TransferCreateViewState();
}

class _TransferCreateViewState extends State<TransferCreateView> {
  final controller = Get.put(TransferController());
  late final WarehouseController warehouseController;
  final remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '新建调拨单',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(icon: TDIcons.chevron_left, iconColor: Colors.white, action: () => Get.back()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWarehouseCard(
                  title: '调出仓库',
                  icon: Icons.warehouse_outlined,
                  color: Colors.orange,
                  warehouse: controller.fromWarehouse,
                  onSelect: () => _showWarehouseSelector(true),
                ),
                const SizedBox(height: 16),
                _buildWarehouseCard(
                  title: '调入仓库',
                  icon: Icons.warehouse,
                  color: const Color(0xFF2FC27D),
                  warehouse: controller.toWarehouse,
                  onSelect: () => _showWarehouseSelector(false),
                ),
                const SizedBox(height: 16),
                _buildItemsCard(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TDText('备注', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TDInput(
                        controller: remarkController,
                        hintText: '输入备注信息（选填）',
                        maxLines: 3,
                        onChanged: (v) => controller.remark.value = v,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildWarehouseCard({
    required String title,
    required IconData icon,
    required Color color,
    required Rxn warehouse,
    required VoidCallback onSelect,
  }) {
    return Container(
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              TDText(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final w = warehouse.value;
            if (w == null) {
              return TDButton(
                text: '选择仓库',
                theme: TDButtonTheme.light,
                size: TDButtonSize.medium,
                isBlock: true,
                icon: TDIcons.add,
                onTap: onSelect,
              );
            }
            return GestureDetector(
              onTap: onSelect,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (w.address != null)
                            TDText(w.address!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
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
              const TDText('调拨商品', style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => TDText('${controller.transferItems.length}种商品', style: const TextStyle(color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.transferItems.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    const TDText('暂无商品', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            return Column(
              children: controller.transferItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TDText(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TDText('编码: ${item.productCode} | 单位: ${item.unit}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            TDText('数量: ${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 24),
                            onPressed: () => controller.updateItemQuantity(index, item.quantity - 1),
                          ),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: TextEditingController(text: item.quantity.toString()),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final qty = int.tryParse(v) ?? 0;
                                controller.updateItemQuantity(index, qty);
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 24),
                            onPressed: () => controller.updateItemQuantity(index, item.quantity + 1),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => controller.removeItem(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 12),
          TDButton(
            text: '添加商品（示例）',
            theme: TDButtonTheme.light,
            size: TDButtonSize.medium,
            isBlock: true,
            icon: TDIcons.add,
            onTap: () => _addSampleItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => TDText('共${controller.transferItems.length}种', style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
            TDButton(
              text: '提交调拨单',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: () async {
                final success = await controller.createTransfer();
                if (success) {
                  Get.back();
                  Get.snackbar('成功', '调拨单创建成功');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWarehouseSelector(bool isFrom) {
    final warehouses = warehouseController.warehouses;
    if (warehouses.isEmpty) {
      warehouseController.loadWarehouses();
    }
    
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: TDText(isFrom ? '选择调出仓库' : '选择调入仓库', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: warehouses.length,
                itemBuilder: (context, index) {
                  final warehouse = warehouses[index];
                  return ListTile(
                    title: Text(warehouse.name),
                    subtitle: warehouse.address != null ? Text(warehouse.address!) : null,
                    trailing: warehouse.isDefault ? const Chip(label: Text('默认'), backgroundColor: Color(0xFFE8F5E9)) : null,
                    onTap: () {
                      if (isFrom) {
                        controller.selectFromWarehouse(warehouse);
                      } else {
                        controller.selectToWarehouse(warehouse);
                      }
                      Get.back();
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _addSampleItem() {
    Get.dialog(
      AlertDialog(
        title: const Text('添加示例商品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('可乐'),
              subtitle: const Text('SP001 | 单位: 瓶'),
              onTap: () {
                controller.addSampleItem('可乐', 'SP001', '瓶', 10);
                Get.back();
              },
            ),
            ListTile(
              title: const Text('雪碧'),
              subtitle: const Text('SP002 | 单位: 瓶'),
              onTap: () {
                controller.addSampleItem('雪碧', 'SP002', '瓶', 10);
                Get.back();
              },
            ),
            ListTile(
              title: const Text('红牛'),
              subtitle: const Text('SP003 | 单位: 罐'),
              onTap: () {
                controller.addSampleItem('红牛', 'SP003', '罐', 5);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
