import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';

class InventoryListView extends GetView<InventoryController> {
  const InventoryListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存明细'),
        backgroundColor: const Color(0xFF2FC27D),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('库存明细页面 - 开发中')),
    );
  }
}
