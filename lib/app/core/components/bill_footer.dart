import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 单据表尾字段类型
enum BillFooterFieldType {
  amount,         // 金额显示
  quantity,       // 数量显示
  input,          // 输入框
  discount,       // 折扣
  payable,        // 应付
  paid,           // 实付
  unpaid,         // 未付
  attachment,     // 附件
}

/// 单据表尾字段配置
class BillFooterField {
  final String key;
  final String label;
  final BillFooterFieldType type;
  final double? value;
  final String? prefix;
  final String? suffix;
  final bool isBold;
  final Color? color;
  final Function(double)? onChanged;

  const BillFooterField({
    required this.key,
    required this.label,
    required this.type,
    this.value,
    this.prefix,
    this.suffix,
    this.isBold = false,
    this.color,
    this.onChanged,
  });
}

/// 统一单据表尾组件
/// 支持金额、数量、折扣、实付、未付等字段
class BillFooter extends StatelessWidget {
  final List<BillFooterField> fields;
  final String submitText;
  final VoidCallback onSubmit;
  final bool showDivider;
  final EdgeInsetsGeometry padding;

  const BillFooter({
    Key? key,
    required this.fields,
    required this.submitText,
    required this.onSubmit,
    this.showDivider = true,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 字段列表
            ...fields.map((field) => _buildField(field)),
            
            if (showDivider && fields.isNotEmpty) ...[
              const Divider(height: 24),
            ],
            
            // 提交按钮
            TDButton(
              text: submitText,
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              isBlock: true,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BillFooterField field) {
    switch (field.type) {
      case BillFooterFieldType.amount:
      case BillFooterFieldType.quantity:
      case BillFooterFieldType.payable:
      case BillFooterFieldType.unpaid:
        return _buildDisplayField(field);
      case BillFooterFieldType.discount:
      case BillFooterFieldType.paid:
        return _buildInputField(field);
      case BillFooterFieldType.input:
        return _buildInputField(field);
      case BillFooterFieldType.attachment:
        return _buildAttachmentField(field);
    }
  }

  Widget _buildDisplayField(BillFooterField field) {
    final value = field.value ?? 0;
    final displayValue = value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            field.label,
            style: TextStyle(
              fontSize: field.isBold ? 14 : 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${field.prefix ?? ''}$displayValue${field.suffix ?? ''}',
            style: TextStyle(
              fontSize: field.isBold ? 16 : 14,
              fontWeight: field.isBold ? FontWeight.bold : FontWeight.normal,
              color: field.color ?? (field.isBold ? const Color(0xFF2FC27D) : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BillFooterField field) {
    final controller = TextEditingController(
      text: field.value != null ? field.value.toString() : '',
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            field.label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: field.prefix,
                prefixStyle: TextStyle(color: Colors.grey[600]),
                suffixText: field.suffix,
                suffixStyle: TextStyle(color: Colors.grey[600]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF2FC27D)),
                ),
              ),
              onChanged: (value) {
                if (field.onChanged != null) {
                  field.onChanged!(double.tryParse(value) ?? 0);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentField(BillFooterField field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            field.label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '添加附件',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 简化版单据表尾（只显示金额和提交按钮）
class SimpleBillFooter extends StatelessWidget {
  final int totalQuantity;
  final double totalAmount;
  final String submitText;
  final VoidCallback onSubmit;
  final String? secondaryText;
  final VoidCallback? onSecondary;

  const SimpleBillFooter({
    Key? key,
    required this.totalQuantity,
    required this.totalAmount,
    required this.submitText,
    required this.onSubmit,
    this.secondaryText,
    this.onSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '共 $totalQuantity 件',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '¥${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2FC27D),
                    ),
                  ),
                ],
              ),
            ),
            if (secondaryText != null && onSecondary != null) ...[
              TDButton(
                text: secondaryText!,
                theme: TDButtonTheme.light,
                size: TDButtonSize.large,
                onTap: onSecondary,
              ),
              const SizedBox(width: 12),
            ],
            TDButton(
              text: submitText,
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

/// 采购单/销售单表尾（带折扣、实付等功能）
class OrderBillFooter extends StatelessWidget {
  final int totalQuantity;
  final double totalAmount;
  final double discountAmount;
  final double paidAmount;
  final Function(double)? onDiscountChanged;
  final Function(double)? onPaidChanged;
  final String submitText;
  final VoidCallback onSubmit;

  const OrderBillFooter({
    Key? key,
    required this.totalQuantity,
    required this.totalAmount,
    this.discountAmount = 0,
    this.paidAmount = 0,
    this.onDiscountChanged,
    this.onPaidChanged,
    required this.submitText,
    required this.onSubmit,
  }) : super(key: key);

  double get payableAmount => totalAmount - discountAmount;
  double get unpaidAmount => payableAmount - paidAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 合计金额
            _buildRow('合计金额', totalAmount, isBold: true),
            
            // 折扣
            if (onDiscountChanged != null)
              _buildInputRow('折扣金额', discountAmount, onDiscountChanged!, prefix: '-¥')
            else if (discountAmount > 0)
              _buildRow('折扣金额', discountAmount, prefix: '-¥'),
            
            // 应付
            _buildRow('应付金额', payableAmount, isBold: true, color: const Color(0xFF2FC27D)),
            
            // 实付
            if (onPaidChanged != null)
              _buildInputRow('实付金额', paidAmount, onPaidChanged!, prefix: '¥'),
            
            // 未付
            if (unpaidAmount > 0)
              _buildRow('未付金额', unpaidAmount, color: Colors.orange),
            
            const Divider(height: 24),
            
            // 底部按钮区
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('共 $totalQuantity 件商品', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        '¥${payableAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2FC27D),
                        ),
                      ),
                    ],
                  ),
                ),
                TDButton(
                  text: submitText,
                  theme: TDButtonTheme.primary,
                  size: TDButtonSize.large,
                  onTap: onSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value, {
    bool isBold = false, 
    String prefix = '¥',
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            '$prefix${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isBold ? const Color(0xFF2FC27D) : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, double value, Function(double) onChanged, {
    String prefix = '¥',
  }) {
    final controller = TextEditingController(text: value > 0 ? value.toString() : '');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: prefix,
                prefixStyle: TextStyle(color: Colors.grey[600]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF2FC27D)),
                ),
              ),
              onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
            ),
          ),
        ],
      ),
    );
  }
}
