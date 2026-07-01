import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_field_base.dart';

/// 带搜索的选择器字段
/// 用于客户、供应商、商品等数据量大的选择
class BillSearchSelectorField<T> extends BillFieldBase {
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) displayMapper;
  final String Function(T) searchKeyMapper;
  final String? bottomSheetTitle;
  final VoidCallback? onCreateNew;
  final String? createNewText;
  final Widget Function(T)? itemDetailBuilder;

  const BillSearchSelectorField({
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
    required this.searchKeyMapper,
    this.bottomSheetTitle,
    this.onCreateNew,
    this.createNewText,
    this.itemDetailBuilder,
  });

  String get _displayText {
    if (value == null) return hintText ?? '请选择$label';
    return displayMapper(value as T);
  }

  void _showSearchSelector(BuildContext context) {
    if (readOnly) return;

    showSearchSelectorBottomSheet<T>(
      context: context,
      title: bottomSheetTitle ?? '选择$label',
      items: items,
      itemBuilder: (item) {
        if (itemDetailBuilder != null) {
          return itemDetailBuilder!(item);
        }
        return TDText(displayMapper(item));
      },
      selectedValue: value,
      searchKeyMapper: searchKeyMapper,
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
      onTap: readOnly ? null : () => _showSearchSelector(context),
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
                    Icons.search,
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
