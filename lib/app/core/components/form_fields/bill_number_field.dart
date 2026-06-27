import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 数字输入字段
/// 用于数量、扩展字段等
class BillNumberField extends BillFieldBase {
  final num? value;
  final ValueChanged<num?>? onChanged;
  final num? min;
  final num? max;
  final int decimalPlaces;
  final String? unit;
  final bool allowNegative;

  const BillNumberField({
    super.key,
    required super.label,
    super.required,
    super.readOnly,
    super.hintText,
    super.padding,
    this.value,
    this.onChanged,
    this.min,
    this.max,
    this.decimalPlaces = 0,
    this.unit,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final textValue = value?.toStringAsFixed(decimalPlaces).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.$'), '') ?? '';

    return Container(
      padding: padding ?? defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TDInput(
                  leftLabel: '',
                  hintText: hintText ?? '请输入$label',
                  text: textValue,
                  readOnly: readOnly,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: decimalPlaces > 0,
                    signed: allowNegative,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(allowNegative ? r'^-?\d*\.?\d*' : r'^\d*\.?\d*'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v.isEmpty) {
                      onChanged?.call(null);
                      return;
                    }
                    final numValue = decimalPlaces > 0 ? double.tryParse(v) : int.tryParse(v);
                    if (numValue != null) {
                      if (min != null && numValue < min!) {
                        onChanged?.call(min);
                        return;
                      }
                      if (max != null && numValue > max!) {
                        onChanged?.call(max);
                        return;
                      }
                      onChanged?.call(numValue);
                    }
                  },
                  backgroundColor: readOnly ? Colors.grey.shade50 : Colors.white,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 8),
                TDText(
                  unit!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
