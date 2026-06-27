import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';

class SupplierFormView extends GetView<SupplierController> {
  const SupplierFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商表单'),
        backgroundColor: const Color(0xFF2FC27D),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('供应商表单页面 - 开发中')),
    );
  }
}
