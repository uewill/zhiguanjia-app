import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import '../controllers/stock_check_controller.dart';
import 'stock_check_scan_view.dart';

class StockCheckCreateView extends StatelessWidget {
  const StockCheckCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockCheckController());
    final warehouseController = Get.put(WarehouseController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '新建盘点单',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TDText('选择仓库', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (warehouseController.warehouses.isEmpty) {
                            return const TDText('暂无仓库，请先创建仓库', style: TextStyle(color: Colors.grey));
                          }
                          return Column(
                            children: warehouseController.warehouses.map((w) {
                              return Obx(() => RadioListTile<int>(
                                title: Text(w.name),
                                subtitle: w.isDefault ? const Text('默认仓库', style: TextStyle(fontSize: 12, color: Colors.grey)) : null,
                                value: w.id,
                                groupValue: controller.selectedWarehouse.value?.id,
                                onChanged: (v) => controller.selectWarehouse(w),
                              ));
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
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
                        const TDText('盘点说明', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const TDText('创建盘点单后，进入扫码盘点页面，通过扫描商品条码快速录入实际库存数量。', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const TDText('系统会自动对比盘点数量与系统数量，生成盘盈盘亏报告。', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: SafeArea(
              child: TDButton(
                text: '开始盘点',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                isBlock: true,
                onTap: () {
                  if (controller.selectedWarehouse.value == null) {
                    Get.snackbar('提示', '请选择盘点仓库');
                    return;
                  }
                  controller.createStockCheck(controller.selectedWarehouse.value!.id);
                  Get.to(() => const StockCheckScanView());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
