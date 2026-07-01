import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../../app/core/data/index.dart';
import '../controllers/customer_controller_new.dart';
import '../models/customer_model.dart';

/// 客户列表页面 - 使用资料类模板
class CustomerListViewNew extends DataListView<CustomerModel> {
  const CustomerListViewNew({Key? key}) : super(key: key);

  @override
  State<DataListView<CustomerModel>> createState() => _CustomerListViewNewState();
}

class _CustomerListViewNewState extends DataListViewState<CustomerModel> {
  @override
  Widget _buildSubtitle(CustomerModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.phone != null && item.phone!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                TDText(item.phone!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        if (item.balance != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TDText(
              '余额: ¥${item.balance!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFF53F3F)),
            ),
          ),
      ],
    );
  }

  @override
  Widget _buildLeadingIcon(CustomerModel item) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2FC27D), const Color(0xFF2FC27D).withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          item.name.isNotEmpty ? item.name.substring(0, 1) : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}