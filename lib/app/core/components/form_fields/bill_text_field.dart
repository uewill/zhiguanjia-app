import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          TextField(
            controller: TextEditingController(text: value ?? ''),
            readOnly: readOnly,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText ?? '请输入$label',
              filled: true,
              fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
