import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../bill/bill_type.dart';

/// 单据页面底部操作栏
class BillBottomBar extends StatelessWidget {
  final BillType billType;
  final int totalQuantity;
  final double totalAmount;
  final VoidCallback onSubmit;

  const BillBottomBar({
    Key? key,
    required this.billType,
    required this.totalQuantity,
    required this.totalAmount,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  TDText(
                    '共${totalQuantity}件',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (billType.requiresAmount)
                    TDText(
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
            TDButton(
              text: billType.submitText,
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

/// 带金额显示的底部栏（用于采购/销售单）
class AmountBottomBar extends StatelessWidget {
  final int totalQuantity;
  final double totalAmount;
  final double? discountAmount;
  final double? payableAmount;
  final double? paidAmount;
  final String submitText;
  final VoidCallback onSubmit;

  const AmountBottomBar({
    Key? key,
    required this.totalQuantity,
    required this.totalAmount,
    this.discountAmount,
    this.payableAmount,
    this.paidAmount,
    required this.submitText,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actualPayable = payableAmount ?? totalAmount - (discountAmount ?? 0);
    final actualPaid = paidAmount ?? 0;
    final unpaid = actualPayable - actualPaid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 金额详情
            if (discountAmount != null && discountAmount! > 0)
              _buildAmountRow('折扣', '-¥${discountAmount!.toStringAsFixed(2)}'),
            _buildAmountRow('应付金额', '¥${actualPayable.toStringAsFixed(2)}', isBold: true),
            if (paidAmount != null && paidAmount! > 0) ...[
              _buildAmountRow('实付金额', '¥${actualPaid.toStringAsFixed(2)}'),
              if (unpaid > 0)
                _buildAmountRow('未付金额', '¥${unpaid.toStringAsFixed(2)}', color: Colors.orange),
            ],
            const Divider(),
            // 提交按钮
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('共${totalQuantity}件商品'),
                      Text(
                        '合计: ¥${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
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

  Widget _buildAmountRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isBold ? const Color(0xFF2FC27D) : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}

/// 简化底部栏
class SimpleBottomBar extends StatelessWidget {
  final String submitText;
  final VoidCallback onSubmit;
  final String? secondaryText;
  final VoidCallback? onSecondary;

  const SimpleBottomBar({
    Key? key,
    required this.submitText,
    required this.onSubmit,
    this.secondaryText,
    this.onSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (secondaryText != null && onSecondary != null) ...[
              Expanded(
                child: TDButton(
                  text: secondaryText!,
                  theme: TDButtonTheme.light,
                  size: TDButtonSize.large,
                  onTap: onSecondary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: TDButton(
                text: submitText,
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                onTap: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
