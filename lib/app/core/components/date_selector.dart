import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 日期选择器组件
class DateSelector extends StatelessWidget {
  final Rx<DateTime> billDate;
  final Rxn<DateTime> expectedDate;
  final Function(DateTime) onBillDateChanged;
  final Function(DateTime?) onExpectedDateChanged;

  const DateSelector({
    Key? key,
    required this.billDate,
    required this.expectedDate,
    required this.onBillDateChanged,
    required this.onExpectedDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TDText('单据日期', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => _buildDatePicker(
            context: context,
            date: billDate.value,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: billDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                onBillDateChanged(date);
              }
            },
          )),
          const SizedBox(height: 12),
          const TDText('预计日期 (选填)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => _buildDatePicker(
            context: context,
            date: expectedDate.value,
            placeholder: '选择日期',
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: expectedDate.value ?? DateTime.now().add(const Duration(days: 3)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                onExpectedDateChanged(date);
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required DateTime? date,
    String? placeholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TDText(
              date != null
                  ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                  : (placeholder ?? '选择日期'),
              style: TextStyle(
                color: date != null ? const Color(0xFF1D2129) : const Color(0xFF86909C),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// 简化日期选择器（单个日期）
class SimpleDateSelector extends StatelessWidget {
  final String label;
  final Rx<DateTime> date;
  final Function(DateTime) onChanged;

  const SimpleDateSelector({
    Key? key,
    required this.label,
    required this.date,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date.value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onChanged(picked);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Obx(() => Text(
                  '${date.value.year}-${date.value.month.toString().padLeft(2, '0')}-${date.value.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
