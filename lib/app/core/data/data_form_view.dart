import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'data_base.dart';
import 'data_controller.dart';

/// 资料表单页面模板 - 模板方法模式
abstract class DataFormView<T extends DataFormController> extends StatefulWidget {
  const DataFormView({Key? key}) : super(key: key);

  @override
  State<DataFormView<T>> createState() => DataFormViewState<T>();
}

class DataFormViewState<T extends DataFormController> extends State<DataFormView<T>> {
  late final T controller;
  
  DataPageConfig get config => controller.config;

  @override
  void initState() {
    super.initState();
    controller = Get.find<T>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: controller.isEditMode.value ? '编辑${config.singularName}' : '新增${config.singularName}',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFormCard(),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 构建表单卡片
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 必须字段：名称
          TDInput(
            controller: controller.nameController,
            leftLabel: '${config.singularName}名称',
            required: true,
            hintText: '请输入${config.singularName}名称',
            leftLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          
          // 可选字段：编码
          if (config.hasCode) ...[
            TDInput(
              controller: controller.codeController,
              leftLabel: '${config.singularName}编码',
              hintText: '请输入编码（可自动生成）',
              leftLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
          ],
          
          // 可选字段：联系电话
          if (config.hasPhone) ...[
            TDInput(
              controller: controller.phoneController,
              leftLabel: '联系电话',
              hintText: '请输入联系电话',
              leftLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              inputType: TextInputType.phone,
            ),
            const Divider(height: 24),
          ],
          
          // 可选字段：地址
          if (config.hasAddress) ...[
            TDInput(
              controller: controller.addressController,
              leftLabel: '地址',
              hintText: '请输入地址',
              leftLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
            ),
            const Divider(height: 24),
          ],
          
          // 子类可覆盖的额外字段
          ...buildExtraFields(),
          
          // 备注
          if (config.hasRemark) ...[
            TDInput(
              controller: controller.remarkController,
              leftLabel: '备注',
              hintText: '请输入备注（选填）',
              leftLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TDButton(
                text: '取消',
                theme: TDButtonTheme.light,
                size: TDButtonSize.large,
                isBlock: true,
                onTap: () => Get.back(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TDButton(
                text: controller.isEditMode.value ? '保存修改' : '保存',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                isBlock: true,
                onTap: _submitForm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 提交表单
  Future<void> _submitForm() async {
    final success = await controller.submit();
    if (success) {
      Get.back(result: true);
    }
  }

  /// 子类可覆盖：构建额外字段
  List<Widget> buildExtraFields() => [];
}

/// 简化表单页面（用于快速新增）
class SimpleDataFormView extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final bool isLoading;

  const SimpleDataFormView({
    Key? key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: title,
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: fields),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: SafeArea(
          child: TDButton(
            text: '保存',
            theme: TDButtonTheme.primary,
            size: TDButtonSize.large,
            isBlock: true,
            onTap: onSubmit,
          ),
        ),
      ),
    );
  }
}
