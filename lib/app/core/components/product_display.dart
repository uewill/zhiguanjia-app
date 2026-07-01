import 'package:flutter/material.dart';
import '../../data/models/product_model.dart' show Product;

/// 商品展示模式
enum ProductDisplayMode {
  compact,      // 紧凑模式（列表项）
  normal,       // 标准模式（卡片）
  detailed,     // 详细模式（带库存、价格等）
  billItem,     // 单据明细模式（带数量、金额编辑）
}

/// 统一商品信息展示组件
class ProductDisplay extends StatelessWidget {
  final Product product;
  final ProductDisplayMode mode;
  final double? quantity;
  final double? price;
  final double? amount;
  final bool showImage;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<double>? onQuantityChanged;
  final ValueChanged<double>? onPriceChanged;

  const ProductDisplay({
    super.key,
    required this.product,
    this.mode = ProductDisplayMode.normal,
    this.quantity,
    this.price,
    this.amount,
    this.showImage = true,
    this.onTap,
    this.onDelete,
    this.onQuantityChanged,
    this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ProductDisplayMode.compact:
        return _buildCompactMode();
      case ProductDisplayMode.normal:
        return _buildNormalMode();
      case ProductDisplayMode.detailed:
        return _buildDetailedMode();
      case ProductDisplayMode.billItem:
        return _buildBillItemMode();
    }
  }

  /// 紧凑模式 - 用于列表项
  Widget _buildCompactMode() {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: showImage ? _buildImage(size: 40) : null,
      title: Row(
        children: [
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildTag(product.unit, color: const Color(0xFF2FC27D)),
        ],
      ),
      subtitle: Text(product.code, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  /// 标准模式 - 卡片展示
  Widget _buildNormalMode() {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (showImage) ...[
                _buildImage(),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 详细模式 - 带库存、价格等
  Widget _buildDetailedMode() {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showImage) ...[
                    _buildImage(),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              // 价格库存信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem('库存', '${product.stock}'),
                  _buildInfoItem('采购价', '¥${product.purchasePrice.toStringAsFixed(2)}'),
                  _buildInfoItem('销售价', '¥${product.salePrice.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 单据明细模式 - 带数量、金额编辑
  Widget _buildBillItemMode() {
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
          // 商品名称和操作
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '编码: ${product.code}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          // 数量、单价、金额
          Row(
            children: [
              // 数量
              Expanded(
                flex: 2,
                child: _buildEditableField(
                  label: '数量',
                  value: quantity ?? 1,
                  suffix: product.unit,
                  onChanged: onQuantityChanged,
                ),
              ),
              const SizedBox(width: 8),
              // 单价
              Expanded(
                flex: 2,
                child: _buildEditableField(
                  label: '单价',
                  value: price ?? 0,
                  prefix: '¥',
                  onChanged: onPriceChanged,
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥${(amount ?? ((quantity ?? 1) * (price ?? 0))).toStringAsFixed(2)}',
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

  Widget _buildImage({double size = 56}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        image: product.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(product.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: product.imageUrl == null
          ? Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: size * 0.5)
          : null,
    );
  }

  Widget _buildInfoRow() {
    final List<Widget> children = [];

    children.add(_buildTag(product.code, color: Colors.grey));
    children.add(const SizedBox(width: 6));
    children.add(_buildTag(product.unit, color: const Color(0xFF2FC27D)));
    children.add(const SizedBox(width: 6));
    children.add(
      Text(
        '库存: ${product.stock}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: children,
    );
  }

  Widget _buildTag(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required double value,
    String? prefix,
    String? suffix,
    ValueChanged<double>? onChanged,
  }) {
    final controller = TextEditingController(
      text: value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                child: onChanged != null
                    ? TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
                      )
                    : Text(
                        controller.text,
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

/// 商品列表组件
class ProductList extends StatelessWidget {
  final List<Product> products;
  final ProductDisplayMode mode;
  final Function(Product)? onProductTap;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;

  const ProductList({
    super.key,
    required this.products,
    this.mode = ProductDisplayMode.compact,
    this.onProductTap,
    this.scrollController,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: padding,
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ProductDisplay(
          product: products[index],
          mode: mode,
          onTap: onProductTap != null ? () => onProductTap!(products[index]) : null,
        );
      },
    );
  }
}

/// 商品网格组件
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product)? onProductTap;
  final int crossAxisCount;
  final double childAspectRatio;

  const ProductGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onProductTap != null ? () => onProductTap!(product) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: product.imageUrl != null
                        ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                        : Icon(Icons.inventory_2_outlined, color: Colors.grey[400]),
                  ),
                ),
                // 信息
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '¥${product.salePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFF53F3F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (product.unit != null)
                              Text(product.unit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
