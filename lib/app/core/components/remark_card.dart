import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 备注输入卡片组件
class RemarkCard extends StatelessWidget {
  final RxString remark;
  final Function(String) onChanged;
  final String? hintText;
  final int maxLines;

  const RemarkCard({
    Key? key,
    required this.remark,
    required this.onChanged,
    this.hintText,
    this.maxLines = 3,
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
          const TDText('备注', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TDInput(
            leftLabel: '',
            hintText: hintText ?? '输入备注信息（选填）',
            maxLines: maxLines,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// 简化备注输入
class SimpleRemarkInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final Function(String)? onChanged;
  final String? hintText;

  const SimpleRemarkInput({
    Key? key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText ?? '输入备注...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      maxLines: 3,
      onChanged: onChanged,
    );
  }
}
