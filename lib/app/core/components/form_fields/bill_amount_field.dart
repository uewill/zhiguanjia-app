import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 金额输入字段
/// 用于表尾的运费、折扣、合计等金额字段
class BillAmountField extends BillFieldBase {
  final double? value;
  final ValueChanged<double?>? onChanged;
  final double? min;
  final double? max;
  final int decimalPlaces;
  final bool showCurrency;
  final String currencySymbol;
  final bool readOnlyStyle;

  const BillAmountField({
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
    this.decimalPlaces = 2,
    this.showCurrency = true,
    this.currencySymbol = '¥',
    this.readOnlyStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final textValue = value?.toStringAsFixed(decimalPlaces).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.$'), '') ?? '';
    final isReadOnly = readOnly || readOnlyStyle;

    return Container(
      padding: padding ?? defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isReadOnly ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isReadOnly ? Colors.grey.shade300 : Colors.grey.shade400,
              ),
            ),
            child: Row(
              children: [
                if (showCurrency)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      currencySymbol,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isReadOnly ? Colors.grey : const Color(0xFF2FC27D),
                      ),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: textValue)
                      ..selection = TextSelection.collapsed(offset: textValue.length),
                    readOnly: isReadOnly,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isReadOnly ? Colors.grey.shade700 : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText ?? '0.00',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    onChanged: (v) {
                      if (v.isEmpty) {
                        onChanged?.call(null);
                        return;
                      }
                      final numValue = double.tryParse(v);
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
