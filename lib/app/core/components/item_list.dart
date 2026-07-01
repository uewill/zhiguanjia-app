import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../bill/bill_controller.dart';
import 'product_info_card.dart';

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
      child: Obx(() => BillItemCard(
        name: item.productName,
        code: item.productCode,
        unit: item.selectedUnit ?? item.unit,
        quantity: item.quantity.value.toDouble(),
        price: item.price ?? 0,
        amount: item.subtotal,
        onQuantityChanged: (v) => onUpdateQuantity(index, v.toInt()),
        onDelete: () => onRemoveItem(index),
      )),
    );
  }
}


