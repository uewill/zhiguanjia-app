import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 商品信息展示卡片
/// 用于单据明细中展示商品基本信息
class ProductInfoCard extends StatelessWidget {
  final String name;
  final String? code;
  final String? unit;
  final String? imageUrl;
  final double? stock;
  final double? price;
  final String? priceLabel;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const ProductInfoCard({
    super.key,
    required this.name,
    this.code,
    this.unit,
    this.imageUrl,
    this.stock,
    this.price,
    this.priceLabel,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        child: Row(
          children: [
            // 商品图片
            _buildImage(),
            const SizedBox(width: 12),
            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildSubInfo(),
                ],
              ),
            ),
            // 右侧价格信息
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 28)
          : null,
    );
  }

  Widget _buildSubInfo() {
    final List<Widget> children = [];

    if (code != null) {
      children.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code!,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    if (unit != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 6));
      children.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2FC27D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            unit!,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2FC27D),
            ),
          ),
        ),
      );
    }

    if (stock != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 6));
      children.add(
        Text(
          '库存: ${stock!.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    if (price != null) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 4));
      children.add(
        Row(
          children: [
            if (priceLabel != null)
              Text(
                '$priceLabel: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            Text(
              '¥${price!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF53F3F),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// 单据明细项展示卡片（带数量、金额编辑）
class BillItemCard extends StatelessWidget {
  final String name;
  final String? code;
  final String? unit;
  final double quantity;
  final double price;
  final double amount;
  final ValueChanged<double>? onQuantityChanged;
  final ValueChanged<double>? onPriceChanged;
  final VoidCallback? onDelete;
  final bool readOnly;

  const BillItemCard({
    super.key,
    required this.name,
    this.code,
    this.unit,
    required this.quantity,
    required this.price,
    required this.amount,
    this.onQuantityChanged,
    this.onPriceChanged,
    this.onDelete,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品名称和删除按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!readOnly && onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          if (code != null) ...[
            const SizedBox(height: 4),
            Text(
              '编码: $code',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 数量、单价、金额
          Row(
            children: [
              // 数量
              Expanded(
                flex: 2,
                child: _buildNumberField(
                  label: '数量',
                  value: quantity,
                  suffix: unit ?? '',
                  onChanged: readOnly ? null : onQuantityChanged,
                ),
              ),
              const SizedBox(width: 8),
              // 单价
              Expanded(
                flex: 2,
                child: _buildNumberField(
                  label: '单价',
                  value: price,
                  prefix: '¥',
                  onChanged: readOnly ? null : onPriceChanged,
                ),
              ),
              const SizedBox(width: 8),
              // 金额
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '金额',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF53F3F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required double value,
    String? prefix,
    String? suffix,
    ValueChanged<double>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: onChanged == null ? Colors.grey[100] : Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Text(prefix, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 2),
              ],
              Expanded(
                child: Text(
                  value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onChanged == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Text(suffix, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 商品列表项（简洁版，用于选择结果展示）
class ProductListTile extends StatelessWidget {
  final String name;
  final String? code;
  final String? unit;
  final double? quantity;
  final double? price;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductListTile({
    super.key,
    required this.name,
    this.code,
    this.unit,
    this.quantity,
    this.price,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (unit != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2FC27D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                unit!,
                style: const TextStyle(fontSize: 11, color: Color(0xFF2FC27D)),
              ),
            ),
        ],
      ),
      subtitle: code != null
          ? Text(code!, style: TextStyle(fontSize: 12, color: Colors.grey[600]))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quantity != null)
            Text(
              '×${quantity!.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          if (price != null) ...[
            const SizedBox(width: 8),
            Text(
              '¥${price!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFF53F3F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
