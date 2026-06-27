import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 单据分割线组件
/// 用于表头、表尾、明细之间的分隔
class BillDivider extends StatelessWidget {
  final String? label;
  final double thickness;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const BillDivider({
    super.key,
    this.label,
    this.thickness = 1,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: padding,
        child: Divider(
          thickness: thickness,
          color: color ?? Colors.grey.shade300,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: thickness,
              color: color ?? Colors.grey.shade300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TDText(
              label!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: thickness,
              color: color ?? Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

/// 分组标题分割线
class BillSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const BillSectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFF2FC27D),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: color ?? const Color(0xFF2FC27D),
            ),
            const SizedBox(width: 6),
          ],
          TDText(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
