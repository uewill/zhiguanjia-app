import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/supplier_controller.dart';

class SupplierView extends GetView<SupplierController> {
  const SupplierView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2FC27D),
        title: const TDText('供应商', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(child: TDText('供应商页面')),
    );
  }
}
