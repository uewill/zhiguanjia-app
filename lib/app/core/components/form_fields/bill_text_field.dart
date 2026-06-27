import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 文本输入字段
/// 用于单号、备注等普通文本输入
class BillTextField extends BillFieldBase {
  final String? value;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const BillTextField({
    super.key,
    required super.label,
    super.required,
    super.readOnly,
    super.hintText,
    super.padding,
    super.suffix,
    this.value,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(),
          const SizedBox(height: 8),
          TDInput(
            leftLabel: '',
            hintText: hintText ?? '请输入$label',
            text: value ?? '',
            readOnly: readOnly,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            backgroundColor: readOnly ? Colors.grey.shade50 : Colors.white,
            rightWidget: suffix,
          ),
        ],
      ),
    );
  }
}
