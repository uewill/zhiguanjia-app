import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/print_template_model.dart';
import '../../../services/print_service.dart';

/// 打印模版管理控制器
class PrintTemplateController extends GetxController {
  final PrintService _printService = Get.find<PrintService>();

  // 模版列表
  final templates = <PrintTemplate>[].obs;
  final filteredTemplates = <PrintTemplate>[].obs;
  final isLoading = false.obs;

  // 筛选
  final selectedType = ''.obs; // ''=全部, receipt, delivery, invoice

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final type = selectedType.value.isEmpty ? null : selectedType.value;
      templates.value = await _printService.getTemplates(type: type);
      _filterTemplates();
    } finally {
      isLoading.value = false;
    }
  }

  void onTypeChanged(String? type) {
    selectedType.value = type ?? '';
    loadTemplates();
  }

  void _filterTemplates() {
    filteredTemplates.value = templates;
  }

  void goToCreate() {
    Get.toNamed('/print/template/edit');
  }

  void goToEdit(PrintTemplate template) {
    Get.toNamed('/print/template/edit', arguments: template);
  }

  Future<void> deleteTemplate(PrintTemplate template) async {
    if (template.isDefault) {
      _showToast('默认模版不能删除');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('是否删除模版"${template.name}"？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _printService.deleteTemplate(template.id);
      if (success) {
        _showToast('删除成功');
        loadTemplates();
      } else {
        _showToast('删除失败');
      }
    }
  }

  Future<void> setAsDefault(PrintTemplate template) async {
    // 将其他同类型模版设为非默认
    for (var i = 0; i < templates.length; i++) {
      if (templates[i].type == template.type && templates[i].id != template.id) {
        templates[i] = templates[i].copyWith(isDefault: false);
        await _printService.updateTemplate(templates[i].id, templates[i]);
      }
    }

    // 设置当前为默认
    final updated = template.copyWith(isDefault: true);
    final success = await _printService.updateTemplate(template.id, updated);

    if (success) {
      _showToast('已设为默认模版');
      loadTemplates();
    } else {
      _showToast('设置失败');
    }
  }

  Future<void> toggleEnabled(PrintTemplate template) async {
    final updated = template.copyWith(isEnabled: !template.isEnabled);
    final success = await _printService.updateTemplate(template.id, updated);

    if (success) {
      loadTemplates();
    } else {
      _showToast('操作失败');
    }
  }

  void previewTemplate(PrintTemplate template) {
    Get.toNamed('/print/template/preview', arguments: template);
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }
}

/// 打印模版编辑器控制器
class PrintTemplateEditorController extends GetxController {
  final PrintService _printService = Get.find<PrintService>();

  // 当前编辑的模版
  late Rx<PrintTemplate> template;

  // 表单控制器
  final nameController = TextEditingController();
  final descController = TextEditingController();

  // 选中的元素
  final selectedElementId = ''.obs;

  // 编辑状态
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 初始化模版
    final existingTemplate = Get.arguments as PrintTemplate?;
    if (existingTemplate != null) {
      template = existingTemplate.obs;
      nameController.text = existingTemplate.name;
      descController.text = existingTemplate.description ?? '';
    } else {
      // 创建新模版
      template = PrintTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        type: 'receipt',
        description: '',
        paperSize: PaperSize.mm80,
        elements: [],
        globalStyle: PrintStyle(fontSize: 12, align: 'left'),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ).obs;
    }
  }

  void onNameChanged(String value) {
    template.value = template.value.copyWith(name: value);
  }

  void onDescriptionChanged(String value) {
    template.value = template.value.copyWith(description: value);
  }

  void onTypeChanged(String? type) {
    if (type != null) {
      template.value = template.value.copyWith(type: type);
      // 根据类型切换默认纸张尺寸
      if (type == 'receipt') {
        template.value = template.value.copyWith(paperSize: PaperSize.mm80);
      } else if (type == 'delivery') {
        template.value = template.value.copyWith(paperSize: PaperSize.a5);
      }
    }
  }

  void onPaperSizeChanged(PaperSize? size) {
    if (size != null) {
      template.value = template.value.copyWith(paperSize: size);
    }
  }

  // 添加元素
  void addElement(String type) {
    final element = PrintElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      style: PrintStyle(fontSize: 12, align: 'left'),
      position: PrintPosition(),
      size: PrintSize(),
    );

    final newElements = [...template.value.elements, element];
    template.value = template.value.copyWith(elements: newElements);
    selectedElementId.value = element.id;
  }

  // 删除元素
  void deleteElement(String elementId) {
    final newElements = template.value.elements
        .where((e) => e.id != elementId)
        .toList();
    template.value = template.value.copyWith(elements: newElements);

    if (selectedElementId.value == elementId) {
      selectedElementId.value = '';
    }
  }

  // 更新元素
  void updateElement(PrintElement element) {
    final newElements = template.value.elements.map((e) {
      return e.id == element.id ? element : e;
    }).toList();
    template.value = template.value.copyWith(elements: newElements);
  }

  // 移动元素位置
  void moveElement(int oldIndex, int newIndex) {
    final elements = [...template.value.elements];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final element = elements.removeAt(oldIndex);
    elements.insert(newIndex, element);
    template.value = template.value.copyWith(elements: elements);
  }

  // 选择元素
  void selectElement(String elementId) {
    selectedElementId.value = elementId;
  }

  // 获取选中的元素
  PrintElement? get selectedElement {
    if (selectedElementId.value.isEmpty) return null;
    return template.value.elements
        .firstWhereOrNull((e) => e.id == selectedElementId.value);
  }

  // 快速添加预设元素（小票常用）
  void addReceiptElements() {
    final presetElements = [
      PrintElement(
        id: 'shop_name_${DateTime.now().millisecondsSinceEpoch}',
        type: 'text',
        field: PrintFields.shopName,
        customText: '我的店铺',
        style: PrintStyle(fontSize: 16, isBold: true, align: 'center'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'line_${DateTime.now().millisecondsSinceEpoch}',
        type: 'line',
        style: PrintStyle(),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'order_no_${DateTime.now().millisecondsSinceEpoch}',
        type: 'text',
        field: PrintFields.orderNo,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'items_${DateTime.now().millisecondsSinceEpoch}',
        type: 'table',
        field: PrintFields.itemsTable,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'total_${DateTime.now().millisecondsSinceEpoch}',
        type: 'text',
        field: PrintFields.totalAmount,
        style: PrintStyle(fontSize: 12, isBold: true, align: 'right'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
    ];

    final newElements = [...template.value.elements, ...presetElements];
    template.value = template.value.copyWith(elements: newElements);
  }

  // 保存模版
  Future<void> saveTemplate() async {
    if (nameController.text.isEmpty) {
      _showToast('请输入模版名称');
      return;
    }

    if (template.value.elements.isEmpty) {
      _showToast('模版至少需要一个元素');
      return;
    }

    isSaving.value = true;
    try {
      final updatedTemplate = template.value.copyWith(
        name: nameController.text,
        description: descController.text,
        updateTime: DateTime.now(),
      );

      // 使用 API 检查模版是否存在
      final existingTemplate = await _printService.getTemplate(updatedTemplate.id);
      final isNew = existingTemplate == null;

      final success = isNew
          ? await _printService.saveTemplate(updatedTemplate)
          : await _printService.updateTemplate(updatedTemplate.id, updatedTemplate);

      if (success) {
        _showToast('保存成功');
        Get.back(result: true);
      } else {
        _showToast('保存失败');
      }
    } finally {
      isSaving.value = false;
    }
  }

  // 预览
  Future<void> preview() async {
    // 创建测试数据
    final testData = _generateTestData();

    final pdfUrl = await _printService.previewPdf(
      templateId: template.value.id,
      data: testData,
    );

    if (pdfUrl != null) {
      Get.toNamed('/print/preview', arguments: {
        'pdfUrl': pdfUrl,
        'template': template.value,
      });
    } else {
      _showToast('预览生成失败');
    }
  }

  Map<String, dynamic> _generateTestData() {
    return {
      PrintFields.shopName: '测试店铺',
      PrintFields.orderNo: 'ORDER20240101001',
      PrintFields.orderTime: DateTime.now().toString(),
      PrintFields.itemsTable: [
        {'name': '商品A', 'spec': '规格1', 'quantity': 2, 'price': 10.0, 'amount': 20.0},
        {'name': '商品B', 'spec': '规格2', 'quantity': 1, 'price': 50.0, 'amount': 50.0},
      ],
      PrintFields.totalQuantity: 3,
      PrintFields.totalAmount: 70.0,
      PrintFields.paymentMethod: '微信支付',
      PrintFields.cashierName: '收银员小李',
      PrintFields.printTime: DateTime.now().toString(),
      PrintFields.customerName: '张三',
      PrintFields.customerPhone: '13800138000',
      PrintFields.customerAddress: '北京市朝阳区xxx街道',
    };
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }
}
