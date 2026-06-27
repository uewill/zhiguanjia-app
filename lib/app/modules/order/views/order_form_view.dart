import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class OrderFormView extends GetView<OrderController> {
  const OrderFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单表单'),
        backgroundColor: const Color(0xFF2FC27D),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('订单表单页面 - 开发中')),
    );
  }
}
