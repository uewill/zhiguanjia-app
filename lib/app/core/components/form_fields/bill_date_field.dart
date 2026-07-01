import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 日期选择字段
/// 用于单据日期、预交日期等
class BillDateField extends BillFieldBase {
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? displayFormat;

  const BillDateField({
    super.key,
    required super.label,
    super.required,
    super.readOnly,
    super.hintText,
    super.padding,
    this.value,
    this.onChanged,
    this.minDate,
    this.maxDate,
    this.displayFormat,
  });

  String get _displayText {
    if (value == null) return hintText ?? '请选择$label';
    final format = displayFormat ?? 'yyyy-MM-dd';
    return _formatDate(value!, format);
  }

  String _formatDate(DateTime date, String format) {
    String result = format;
    result = result.replaceAll('yyyy', date.year.toString().padLeft(4, '0'));
    result = result.replaceAll('MM', date.month.toString().padLeft(2, '0'));
    result = result.replaceAll('dd', date.day.toString().padLeft(2, '0'));
    return result;
  }

  Future<void> _showDatePicker(BuildContext context) async {
    if (readOnly) return;

    final now = DateTime.now();
    final initial = value ?? now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate ?? DateTime(2000),
      lastDate: maxDate ?? DateTime(2100),
      helpText: '选择$label',
      cancelText: '取消',
      confirmText: '确定',
    );
    
    if (picked != null) {
      onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? null : () => _showDatePicker(context),
      child: Container(
        padding: padding ?? defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: readOnly ? Colors.grey.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: readOnly ? Colors.grey.shade300 : Colors.grey.shade400,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: readOnly ? Colors.grey : const Color(0xFF2FC27D),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TDText(
                      _displayText,
                      style: TextStyle(
                        fontSize: 14,
                        color: value == null ? Colors.grey.shade500 : Colors.black,
                      ),
                    ),
                  ),
                  if (!readOnly)
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
