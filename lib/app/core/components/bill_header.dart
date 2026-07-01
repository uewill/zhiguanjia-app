import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 单据表头字段类型
enum BillHeaderFieldType {
  text,           // 普通文本
  number,         // 数字
  date,           // 日期
  selector,       // 选择器
  warehouse,      // 仓库选择
  partner,        // 往来单位（客户/供应商）
  remark,         // 备注
}

/// 单据表头字段配置
class BillHeaderField {
  final String key;
  final String label;
  final BillHeaderFieldType type;
  final bool required;
  final String? placeholder;
  final IconData? icon;
  final Color? iconColor;
  final dynamic value;
  final List<dynamic>? options;  // 选择器选项
  final Function(dynamic)? onChanged;
  final VoidCallback? onTap;

  const BillHeaderField({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.icon,
    this.iconColor,
    this.value,
    this.options,
    this.onChanged,
    this.onTap,
  });
}

/// 统一单据表头组件
/// 支持多种字段类型：文本、数字、日期、选择器、仓库、往来单位、备注
class BillHeader extends StatelessWidget {
  final List<BillHeaderField> fields;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const BillHeader({
    Key? key,
    required this.fields,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildFields(),
      ),
    );
  }

  List<Widget> _buildFields() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < fields.length; i++) {
      widgets.add(_buildField(fields[i]));
      if (i < fields.length - 1) {
        widgets.add(SizedBox(height: spacing));
      }
    }
    
    return widgets;
  }

  Widget _buildField(BillHeaderField field) {
    switch (field.type) {
      case BillHeaderFieldType.text:
        return _buildTextField(field);
      case BillHeaderFieldType.number:
        return _buildNumberField(field);
      case BillHeaderFieldType.date:
        return _buildDateField(field);
      case BillHeaderFieldType.selector:
        return _buildSelectorField(field);
      case BillHeaderFieldType.warehouse:
        return _buildWarehouseField(field);
      case BillHeaderFieldType.partner:
        return _buildPartnerField(field);
      case BillHeaderFieldType.remark:
        return _buildRemarkField(field);
    }
  }

  Widget _buildTextField(BillHeaderField field) {
    return _buildFieldContainer(
      field: field,
      child: TextField(
        controller: TextEditingController(text: field.value?.toString() ?? ''),
        decoration: _inputDecoration(field.placeholder ?? '请输入${field.label}'),
        onChanged: field.onChanged as ValueChanged<String>?,
      ),
    );
  }

  Widget _buildNumberField(BillHeaderField field) {
    return _buildFieldContainer(
      field: field,
      child: TextField(
        controller: TextEditingController(text: field.value?.toString() ?? ''),
        keyboardType: TextInputType.number,
        decoration: _inputDecoration(field.placeholder ?? '请输入${field.label}'),
        onChanged: (value) {
          if (field.onChanged != null) {
            field.onChanged!(double.tryParse(value) ?? 0);
          }
        },
      ),
    );
  }

  Widget _buildDateField(BillHeaderField field) {
    final date = field.value as DateTime?;
    return _buildFieldContainer(
      field: field,
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: Get.context!,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null && field.onChanged != null) {
            field.onChanged!(picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null
                    ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                    : (field.placeholder ?? '选择${field.label}'),
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey[500],
                ),
              ),
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorField(BillHeaderField field) {
    final options = field.options ?? [];
    final selectedValue = field.value;
    final selectedOption = options.firstWhereOrNull(
      (o) => o['value'] == selectedValue || o.value == selectedValue,
    );
    
    return _buildFieldContainer(
      field: field,
      child: GestureDetector(
        onTap: () => _showSelectorBottomSheet(field, options),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedOption != null
                      ? (selectedOption['label'] ?? selectedOption.label ?? '')
                      : (field.placeholder ?? '选择${field.label}'),
                  style: TextStyle(
                    color: selectedOption != null ? Colors.black87 : Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarehouseField(BillHeaderField field) {
    final warehouse = field.value as Map<String, dynamic>?;
    
    return _buildFieldContainer(
      field: field,
      child: GestureDetector(
        onTap: field.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: warehouse != null 
                ? (field.iconColor ?? const Color(0xFF2FC27D)).withValues(alpha: 0.1)
                : Colors.grey[50],
            border: Border.all(
              color: warehouse != null 
                  ? (field.iconColor ?? const Color(0xFF2FC27D)).withValues(alpha: 0.3)
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (field.icon != null) ...[
                Icon(field.icon, color: field.iconColor, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse != null 
                          ? (warehouse['name'] ?? '')
                          : (field.placeholder ?? '选择${field.label}'),
                      style: TextStyle(
                        fontWeight: warehouse != null ? FontWeight.bold : FontWeight.normal,
                        color: warehouse != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    if (warehouse != null && warehouse['address'] != null)
                      Text(
                        warehouse['address'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerField(BillHeaderField field) {
    final partner = field.value as Map<String, dynamic>?;
    
    return _buildFieldContainer(
      field: field,
      child: GestureDetector(
        onTap: field.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: partner != null 
                ? (field.iconColor ?? Colors.blue).withValues(alpha: 0.1)
                : Colors.grey[50],
            border: Border.all(
              color: partner != null 
                  ? (field.iconColor ?? Colors.blue).withValues(alpha: 0.3)
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (field.icon != null) ...[
                Icon(field.icon, color: field.iconColor, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner != null 
                          ? (partner['name'] ?? '')
                          : (field.placeholder ?? '选择${field.label}'),
                      style: TextStyle(
                        fontWeight: partner != null ? FontWeight.bold : FontWeight.normal,
                        color: partner != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    if (partner != null && partner['phone'] != null)
                      Text(
                        partner['phone'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemarkField(BillHeaderField field) {
    return _buildFieldContainer(
      field: field,
      child: TextField(
        controller: TextEditingController(text: field.value?.toString() ?? ''),
        maxLines: 3,
        decoration: _inputDecoration(field.placeholder ?? '添加备注说明...'),
        onChanged: field.onChanged as ValueChanged<String>?,
      ),
    );
  }

  Widget _buildFieldContainer({
    required BillHeaderField field,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (field.icon != null && field.type != BillHeaderFieldType.warehouse && field.type != BillHeaderFieldType.partner)
              Icon(field.icon, size: 16, color: field.iconColor ?? Colors.grey),
            if (field.icon != null && field.type != BillHeaderFieldType.warehouse && field.type != BillHeaderFieldType.partner)
              const SizedBox(width: 4),
            Text(
              field.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (field.required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2FC27D)),
      ),
    );
  }

  void _showSelectorBottomSheet(BillHeaderField field, List<dynamic> options) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择${field.label}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = field.value == (option['value'] ?? option.value);
                  
                  return ListTile(
                    title: Text(option['label'] ?? option.label ?? ''),
                    trailing: isSelected 
                        ? const Icon(Icons.check, color: Color(0xFF2FC27D))
                        : null,
                    onTap: () {
                      if (field.onChanged != null) {
                        field.onChanged!(option['value'] ?? option.value);
                      }
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简化版单据表头（用于只需要几个字段的场景）
class SimpleBillHeader extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const SimpleBillHeader({
    Key? key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}

/// 表头字段行（用于横向排列的字段）
class BillHeaderRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const BillHeaderRow({
    Key? key,
    required this.children,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(Expanded(child: children[i]));
      if (i < children.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }
}
