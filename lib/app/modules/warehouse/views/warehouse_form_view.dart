import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/warehouse_model.dart';
import '../controllers/warehouse_controller.dart';

class WarehouseFormView extends StatefulWidget {
  final Warehouse? warehouse;
  const WarehouseFormView({Key? key, this.warehouse}) : super(key: key);

  @override
  State<WarehouseFormView> createState() => _WarehouseFormViewState();
}

class _WarehouseFormViewState extends State<WarehouseFormView> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();
  final phoneController = TextEditingController();
  bool isDefault = false;

  late final WarehouseController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    if (widget.warehouse != null) {
      nameController.text = widget.warehouse!.name;
      codeController.text = widget.warehouse!.code ?? '';
      addressController.text = widget.warehouse!.address ?? '';
      contactController.text = widget.warehouse!.contact ?? '';
      phoneController.text = widget.warehouse!.phone ?? '';
      isDefault = widget.warehouse!.isDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: widget.warehouse == null ? '新增仓库' : '编辑仓库',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TDInput(
                    controller: nameController,
                    leftLabel: '仓库名称',
                    hintText: '请输入仓库名称',
                    backgroundColor: Colors.white,
                  ),
                  TDInput(
                    controller: codeController,
                    leftLabel: '仓库编码',
                    hintText: '请输入仓库编码（可选）',
                    backgroundColor: Colors.white,
                  ),
                  TDInput(
                    controller: addressController,
                    leftLabel: '仓库地址',
                    hintText: '请输入仓库地址（可选）',
                    backgroundColor: Colors.white,
                  ),
                  TDInput(
                    controller: contactController,
                    leftLabel: '联系人',
                    hintText: '请输入联系人（可选）',
                    backgroundColor: Colors.white,
                  ),
                  TDInput(
                    controller: phoneController,
                    leftLabel: '联系电话',
                    hintText: '请输入联系电话（可选）',
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TDText('设为默认仓库'),
                      TDSwitch(
                        isOn: isDefault,
                        onChanged: (v) {
                          setState(() {
                            isDefault = v;
                          });
                          return true;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TDButton(
              text: widget.warehouse == null ? '保存' : '更新',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              isBlock: true,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (nameController.text.isEmpty) {
      Get.snackbar('提示', '请输入仓库名称');
      return;
    }

    final data = {
      'name': nameController.text,
      'code': codeController.text.isEmpty ? null : codeController.text,
      'address': addressController.text.isEmpty ? null : addressController.text,
      'contact': contactController.text.isEmpty ? null : contactController.text,
      'phone': phoneController.text.isEmpty ? null : phoneController.text,
      'isDefault': isDefault,
    };

    if (widget.warehouse == null) {
      controller.createWarehouse(data).then((success) {
        if (success) Get.back();
      });
    } else {
      controller.updateWarehouse(widget.warehouse!.id, data).then((success) {
        if (success) Get.back();
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    addressController.dispose();
    contactController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
