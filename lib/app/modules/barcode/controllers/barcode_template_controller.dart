import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/barcode_template_model.dart';
import '../../../services/barcode_print_service.dart';

/// 条码模版管理控制器
class BarcodeTemplateController extends GetxController {
  final BarcodePrintService _barcodeService = Get.find<BarcodePrintService>();

  // 模版列表
  final templates = <BarcodeTemplate>[].obs;
  final filteredTemplates = <BarcodeTemplate>[].obs;
  final isLoading = false.obs;

  // 筛选
  final selectedType = BarcodeTemplateType.single.obs;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      templates.value = await _barcodeService.getTemplates();
      _filterTemplates();
    } finally {
      isLoading.value = false;
    }
  }

  void onTypeChanged(BarcodeTemplateType? type) {
    if (type != null) {
      selectedType.value = type;
      _filterTemplates();
    }
  }

  void _filterTemplates() {
    filteredTemplates.value = templates
        .where((t) => t.type == selectedType.value)
        .toList();
  }

  void goToCreate() {
    Get.toNamed('/barcode/template/edit');
  }

  void goToEdit(BarcodeTemplate template) {
    Get.toNamed('/barcode/template/edit', arguments: template);
  }

  Future<void> deleteTemplate(BarcodeTemplate template) async {
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
      final success = await _barcodeService.saveTemplate(
        template.copyWith(isEnabled: false),
      );
      if (success) {
        _showToast('删除成功');
        loadTemplates();
      } else {
        _showToast('删除失败');
      }
    }
  }

  void previewTemplate(BarcodeTemplate template) {
    // 显示预览弹窗
    Get.dialog(
      AlertDialog(
        title: Text(template.name),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPreviewWidget(template),
              const SizedBox(height: 16),
              Text('${template.labelSize.width}x${template.labelSize.height}mm'),
              Text('${template.elements.length} 个元素'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
          TDButton(
            text: '测试打印',
            theme: TDButtonTheme.primary,
            onTap: () {
              Get.back();
              _testPrint(template);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewWidget(BarcodeTemplate template) {
    final scale = 4.0;
    final width = template.labelSize.width * scale;
    final height = template.labelSize.height * scale;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: template.elements.map((e) => Positioned(
          left: e.x * scale,
          top: e.y * scale,
          child: _buildElementPreview(e),
        )).toList(),
      ),
    );
  }

  Widget _buildElementPreview(BarcodeElement element) {
    switch (element.type) {
      case BarcodeElementType.barcode:
        return Container(
          width: 60,
          height: 24,
          color: Colors.grey.shade200,
          child: const Icon(Icons.barcode_reader, size: 20),
        );
      case BarcodeElementType.qrcode:
        return Container(
          width: 30,
          height: 30,
          color: Colors.grey.shade200,
          child: const Icon(Icons.qr_code, size: 20),
        );
      case BarcodeElementType.productName:
        return Container(
          padding: const EdgeInsets.all(2),
          color: Colors.blue.shade50,
          child: const Text('名称', style: TextStyle(fontSize: 8)),
        );
      case BarcodeElementType.price:
        return Container(
          padding: const EdgeInsets.all(2),
          color: Colors.orange.shade50,
          child: const Text('¥99', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _testPrint(BarcodeTemplate template) async {
    // 测试数据
    final testProduct = {
      'barcode': '6901234567890',
      'name': '测试商品',
      'spec': '500ml/瓶',
      'salePrice': 29.90,
    };

    try {
      final success = await _barcodeService.printBarcode(
        template: template,
        productData: testProduct,
      );
      if (success) {
        _showToast('打印指令已发送');
      }
    } catch (e) {
      _showToast('打印失败: $e');
    }
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }
}

/// 条码模版编辑器控制器
class BarcodeTemplateEditorController extends GetxController {
  // 当前编辑的模版
  final template = Rx<BarcodeTemplate?>(null);

  // 表单控制器
  final nameController = TextEditingController();

  // 编辑状态
  final selectedType = BarcodeTemplateType.single.obs;
  final labelSize = BarcodeLabelSize.standard40x30.obs;
  final elements = <BarcodeElement>[].obs;
  final selectedElementId = ''.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 初始化模版
    final existingTemplate = Get.arguments as BarcodeTemplate?;
    if (existingTemplate != null) {
      template.value = existingTemplate;
      nameController.text = existingTemplate.name;
      selectedType.value = existingTemplate.type;
      labelSize.value = existingTemplate.labelSize;
      elements.value = existingTemplate.elements;
    } else {
      // 创建新模版
      selectedType.value = BarcodeTemplateType.single;
      labelSize.value = BarcodeLabelSize.standard40x30;
      elements.value = [];
    }
  }

  void onNameChanged(String value) {
    // 名称变更
  }

  void onTypeChanged(BarcodeTemplateType type) {
    selectedType.value = type;
    // 根据类型调整默认尺寸
    switch (type) {
      case BarcodeTemplateType.single:
        labelSize.value = BarcodeLabelSize.standard40x30;
        break;
      case BarcodeTemplateType.priceTag:
        labelSize.value = BarcodeLabelSize.standard50x30;
        break;
      case BarcodeTemplateType.sheet:
        labelSize.value = BarcodeLabelSize.a4Sheet2x5;
        break;
      case BarcodeTemplateType.shelfTag:
        labelSize.value = BarcodeLabelSize.standard50x40;
        break;
    }
  }

  void onLabelSizeChanged(BarcodeLabelSize size) {
    labelSize.value = size;
  }

  // 添加元素
  void addElement(BarcodeElementType type) {
    final element = BarcodeElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      x: 2,
      y: elements.isEmpty ? 2 : elements.last.y + 10,
      style: BarcodeElementStyle(fontSize: 10),
    );
    elements.add(element);
    selectedElementId.value = element.id;
  }

  // 删除元素
  void deleteElement(String elementId) {
    elements.removeWhere((e) => e.id == elementId);
    if (selectedElementId.value == elementId) {
      selectedElementId.value = '';
    }
  }

  // 更新元素
  void updateElement(BarcodeElement element) {
    final index = elements.indexWhere((e) => e.id == element.id);
    if (index >= 0) {
      elements[index] = element;
    }
  }

  // 更新元素位置
  void updateElementPosition(String elementId, double x, double y) {
    final index = elements.indexWhere((e) => e.id == elementId);
    if (index >= 0) {
      elements[index] = elements[index].copyWith(
        x: x.clamp(0, labelSize.value.width),
        y: y.clamp(0, labelSize.value.height),
      );
    }
  }

  // 选择元素
  void selectElement(String elementId) {
    selectedElementId.value = elementId;
  }

  // 清除选择
  void clearSelection() {
    selectedElementId.value = '';
  }

  // 获取选中的元素
  BarcodeElement? get selectedElement {
    if (selectedElementId.value.isEmpty) return null;
    return elements.firstWhereOrNull((e) => e.id == selectedElementId.value);
  }

  // 保存模版
  Future<void> saveTemplate() async {
    if (nameController.text.isEmpty) {
      _showToast('请输入模版名称');
      return;
    }

    if (elements.isEmpty) {
      _showToast('模版至少需要一个元素');
      return;
    }

    isSaving.value = true;
    try {
      final newTemplate = BarcodeTemplate(
        id: template.value?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        type: selectedType.value,
        labelSize: labelSize.value,
        elements: elements.toList(),
        isDefault: template.value?.isDefault ?? false,
        isEnabled: true,
        createTime: template.value?.createTime ?? DateTime.now(),
        updateTime: DateTime.now(),
      );

      final service = Get.find<BarcodePrintService>();
      final success = await service.saveTemplate(newTemplate);

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

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
