import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../../app/core/data/index.dart';
import '../controllers/customer_form_controller.dart';

/// 客户表单页面 - 使用资料类模板
class CustomerFormViewNew extends DataFormView<CustomerFormController> {
  const CustomerFormViewNew({Key? key}) : super(key: key);

  @override
  State<DataFormView<CustomerFormController>> createState() => _CustomerFormViewNewState();
}

class _CustomerFormViewNewState extends DataFormViewState<CustomerFormController> {
  @override
  List<Widget> buildExtraFields() {
    return [
      TDInput(
        controller: controller.nameController, // 联系人使用同一个，实际可分开
        leftLabel: '联系人',
        hintText: '请输入联系人姓名',
        leftLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const Divider(height: 24),
    ];
  }
}