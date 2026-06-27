import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 仓库选择器组件
class WarehouseSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Rxn<Map<String, dynamic>> selectedWarehouse;
  final VoidCallback onSelect;

  const WarehouseSelector({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selectedWarehouse,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              TDText(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final warehouse = selectedWarehouse.value;
            if (warehouse == null) {
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
                          TDText(
                            warehouse['name'] ?? warehouse.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (warehouse['address'] != null || warehouse.address != null)
                            TDText(
                              warehouse['address'] ?? warehouse.address ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
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
}

/// 仓库选择器底部弹窗
class WarehouseSelectorBottomSheet extends StatelessWidget {
  final String title;
  final dynamic controller;
  final Function(dynamic) onSelect;

  const WarehouseSelectorBottomSheet({
    Key? key,
    required this.title,
    required this.controller,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TDText(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Obx(() {
              final warehouses = controller.warehouses ?? [];
              if (warehouses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warehouse_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      TDText('暂无仓库', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: warehouses.length,
                itemBuilder: (context, index) {
                  final warehouse = warehouses[index];
                  final isDefault = warehouse['isDefault'] == true || warehouse.isDefault == true;
                  
                  return ListTile(
                    title: Row(
                      children: [
                        Text(warehouse['name'] ?? warehouse.name ?? ''),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2FC27D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '默认',
                              style: TextStyle(fontSize: 10, color: Color(0xFF2FC27D)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: warehouse['address'] != null || warehouse.address != null
                        ? Text(warehouse['address'] ?? warehouse.address ?? '')
                        : null,
                    onTap: () => onSelect(warehouse),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
