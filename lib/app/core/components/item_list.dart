import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../bill/bill_controller.dart';

/// 单据明细列表组件
class ItemList extends StatelessWidget {
  final String label;
  final RxList<BillItem> items;
  final VoidCallback onAddItem;
  final Function(int index, int quantity) onUpdateQuantity;
  final Function(int index) onRemoveItem;

  const ItemList({
    Key? key,
    required this.label,
    required this.items,
    required this.onAddItem,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TDText(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => TDText('${items.length}种商品', style: const TextStyle(color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (items.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: items.asMap().entries.map((entry) {
                return _buildItemCard(entry.key, entry.value);
              }).toList(),
            );
          }),
          const SizedBox(height: 12),
          TDButton(
            text: '添加商品',
            theme: TDButtonTheme.light,
            size: TDButtonSize.medium,
            isBlock: true,
            icon: TDIcons.add,
            onTap: onAddItem,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildItemCard(int index, BillItem item) {
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
                TDText(
                  item.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TDText(
                      '单价: ¥${(item.price ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (item.selectedUnit != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.selectedUnit!,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF7B1FA2)),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.productCode != null)
                  TDText(
                    '编码: ${item.productCode}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          // 数量控制
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 24),
                onPressed: () => onUpdateQuantity(index, item.quantity.value - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              SizedBox(
                width: 40,
                child: Obx(() => Text(
                  '${item.quantity.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 24),
                onPressed: () => onUpdateQuantity(index, item.quantity.value + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => onRemoveItem(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

/// 简化的明细项卡片（用于只读展示）
class ItemListTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final int quantity;
  final String? unit;
  final double? price;
  final VoidCallback? onDelete;

  const ItemListTile({
    Key? key,
    required this.name,
    this.subtitle,
    required this.quantity,
    this.unit,
    this.price,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${quantity}${unit ?? '件'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (price != null)
                Text(
                  '¥${(price! * quantity).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
