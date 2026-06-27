import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/stock_check_controller.dart';

class StockCheckScanView extends StatelessWidget {
  const StockCheckScanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockCheckController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '扫码盘点',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
      ),
      body: Column(
        children: [
          // 扫码按钮
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TDButton(
                  text: '📷 扫描条码',
                  theme: TDButtonTheme.primary,
                  size: TDButtonSize.large,
                  isBlock: true,
                  onTap: () => _showScanDialog(controller),
                ),
                const SizedBox(height: 8),
                const TDText('点击扫描商品条码，快速录入实际库存', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          // 已盘点列表
          Expanded(
            child: Obx(() {
              if (controller.checkItems.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      TDText('还没有盘点商品', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      TDText('点击上方扫码按钮开始盘点', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.checkItems.length,
                itemBuilder: (context, index) {
                  final item = controller.checkItems[index];
                  final diff = item.diff;
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
                            Expanded(
                              child: TDText(item.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            if (diff > 0)
                              TDText('+盈$diff', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                            else if (diff < 0)
                              TDText('亏${-diff}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                            else
                              const TDText('正常', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TDText('系统: ${item.systemStock}  实盘: ${item.checkStock}', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (item.checkStock > 0) {
                                  controller.updateCheckStock(index, item.checkStock - 1);
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: item.checkStock.toString()),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final stock = int.tryParse(v) ?? 0;
                                  controller.updateCheckStock(index, stock);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => controller.updateCheckStock(index, item.checkStock + 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          // 完成盘点按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: SafeArea(
              child: Obx(() => TDButton(
                text: '完成盘点 (${controller.checkItems.length}项)',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                isBlock: true,
                disabled: controller.checkItems.isEmpty,
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('确认完成'),
                      content: Text('共盘点 ${controller.checkItems.length} 个商品，确认完成盘点？'),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            // 模拟完成
                            Get.back();
                            Get.snackbar('成功', '盘点完成，已生成盘盈盘亏报告');
                          },
                          child: const Text('确认', style: TextStyle(color: Color(0xFF2FC27D))),
                        ),
                      ],
                    ),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanDialog(StockCheckController controller) {
    final codeController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('扫描条码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TDInput(
              controller: codeController,
              hintText: '输入条形码或商品编码',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                // 模拟扫描结果
                controller.addCheckItem({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'name': '商品-${codeController.text.substring(0, codeController.text.length > 6 ? 6 : codeController.text.length)}',
                  'code': codeController.text,
                  'barcode': codeController.text,
                  'unit': '件',
                  'stock': 100,
                  'purchasePrice': 10.0,
                });
                Get.back();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
