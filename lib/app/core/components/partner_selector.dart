import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 合作方选择器组件
/// 用于采购单的供应商、销售单的客户选择
class PartnerSelector extends StatelessWidget {
  final String label;
  final Rxn<Map<String, dynamic>> selectedPartner;
  final Color primaryColor;
  final VoidCallback onSelect;

  const PartnerSelector({
    Key? key,
    required this.label,
    required this.selectedPartner,
    required this.primaryColor,
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
              Icon(
                label == '客户' ? Icons.person : Icons.business,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              TDText(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final partner = selectedPartner.value;
            if (partner == null) {
              return TDButton(
                text: '选择$label',
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
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(
                            partner['name']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (partner['contact'] != null)
                            TDText(
                              '联系人: ${partner['contact']}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryColor),
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

/// 合作方选择器底部弹窗
class PartnerSelectorBottomSheet extends StatelessWidget {
  final String title;
  final dynamic controller;
  final Function(dynamic) onSelect;

  const PartnerSelectorBottomSheet({
    Key? key,
    required this.title,
    required this.controller,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TDText(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索$title',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: (v) {
                controller.search?.call(v);
              },
            ),
          ),
          // 列表
          Expanded(
            child: Obx(() {
              final items = controller.items ?? controller.suppliers ?? controller.customers ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      TDText('暂无数据', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['name']?.toString() ?? ''),
                    subtitle: item['contact'] != null
                        ? Text('联系人: ${item['contact']}')
                        : null,
                    trailing: item['phone'] != null
                        ? Text(item['phone']?.toString() ?? '')
                        : null,
                    onTap: () => onSelect(item),
                  );
                },
              );
            }),
          ),
          // 新增按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TDButton(
              text: '新增$title',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              isBlock: true,
              icon: TDIcons.add,
              onTap: () {
                Get.back();
                // 导航到对应的新建页面
                if (title.contains('供应商')) {
                  Get.toNamed('/supplier/form');
                } else if (title.contains('客户')) {
                  Get.toNamed('/customer/form');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
