import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/purchase_controller.dart';

class PurchaseView extends GetView<PurchaseController> {
  const PurchaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2FC27D),
        title: const TDText('采购', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(child: TDText('采购页面')),
    );
  }
}
