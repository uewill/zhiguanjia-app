import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 备注输入字段
/// 用于单据备注、说明等长文本输入
class BillRemarkField extends BillFieldBase {
  final String? value;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;

  const BillRemarkField({
    super.key,
    required super.label,
    super.required,
    super.readOnly,
    super.hintText,
    super.padding,
    this.value,
    this.onChanged,
    this.maxLines = 3,
    this.maxLength,
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
          Container(
            decoration: BoxDecoration(
              color: readOnly ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: readOnly ? Colors.grey.shade300 : Colors.grey.shade400,
              ),
            ),
            child: TextField(
              controller: TextEditingController(text: value ?? '')
                ..selection = TextSelection.collapsed(offset: (value ?? '').length),
              readOnly: readOnly,
              maxLines: maxLines,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hintText ?? '请输入$label',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
                counterText: maxLength != null ? '${(value ?? '').length}/$maxLength' : null,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
