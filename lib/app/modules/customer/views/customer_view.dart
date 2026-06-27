import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2FC27D),
        title: const TDText('客户', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(child: TDText('客户页面')),
    );
  }
}
