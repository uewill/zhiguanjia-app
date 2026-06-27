import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 选择器字段
/// 用于结算方式、业务员等选项
class BillSelectorField<T> extends BillFieldBase {
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) displayMapper;
  final String? bottomSheetTitle;
  final VoidCallback? onCreateNew;
  final String? createNewText;

  const BillSelectorField({
    super.key,
    required super.label,
    super.required,
    super.readOnly,
    super.hintText,
    super.padding,
    this.value,
    required this.items,
    this.onChanged,
    required this.displayMapper,
    this.bottomSheetTitle,
    this.onCreateNew,
    this.createNewText,
  });

  String get _displayText {
    if (value == null) return hintText ?? '请选择$label';
    return displayMapper(value as T);
  }

  void _showSelector(BuildContext context) {
    if (readOnly || items.isEmpty) return;

    showSelectorBottomSheet<T>(
      context: context,
      title: bottomSheetTitle ?? '选择$label',
      items: items,
      itemBuilder: (item) => TDText(displayMapper(item)),
      selectedValue: value,
      onCreateNew: onCreateNew,
      createNewText: createNewText,
    ).then((selected) {
      if (selected != null) {
        onChanged?.call(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? null : () => _showSelector(context),
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
