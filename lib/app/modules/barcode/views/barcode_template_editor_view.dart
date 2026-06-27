import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/barcode_template_model.dart';
import '../controllers/barcode_template_controller.dart';

/// 条码模版设计器页面
class BarcodeTemplateEditorView extends StatelessWidget {
  const BarcodeTemplateEditorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BarcodeTemplateEditorController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('条码模版设计'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TDButton(
            text: '保存',
            theme: TDButtonTheme.primary,
            onTap: controller.saveTemplate,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 顶部工具栏
          _buildToolbar(controller),
          
          // 标签预览区域
          Expanded(
            child: _buildPreviewArea(controller),
          ),
          
          // 底部属性面板
          _buildPropertyPanel(controller),
        ],
      ),
    );
  }

  /// 工具栏
  Widget _buildToolbar(BarcodeTemplateEditorController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          // 模版基本信息
          Row(
            children: [
              Expanded(
                child: TDInput(
                  controller: controller.nameController,
                  leftLabel: '模版名称',
                  hintText: '输入模版名称',
                  onChanged: controller.onNameChanged,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: Obx(() => TDCell(
                  title: '类型',
                  note: controller.selectedType.value.displayName,
                  arrow: true,
                  onClick: (cell) => _showTypePicker(controller),
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 标签尺寸选择
          Row(
            children: [
              Expanded(
                child: Obx(() => TDCell(
                  title: '标签尺寸',
                  note: '${controller.labelSize.value.width}x${controller.labelSize.value.height}mm',
                  arrow: true,
                  onClick: (cell) => _showSizePicker(controller),
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 元素工具栏
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolButton('一维码', Icons.barcode_reader, () => controller.addElement(BarcodeElementType.barcode)),
                _buildToolButton('二维码', Icons.qr_code, () => controller.addElement(BarcodeElementType.qrcode)),
                _buildToolButton('商品名', Icons.text_fields, () => controller.addElement(BarcodeElementType.productName)),
                _buildToolButton('规格', Icons.description, () => controller.addElement(BarcodeElementType.productSpec)),
                _buildToolButton('价格', Icons.attach_money, () => controller.addElement(BarcodeElementType.price)),
                _buildToolButton('文本', Icons.title, () => controller.addElement(BarcodeElementType.text)),
                _buildToolButton('分割线', Icons.horizontal_rule, () => controller.addElement(BarcodeElementType.line)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TDButton(
        text: label,
        icon: icon,
        size: TDButtonSize.small,
        type: TDButtonType.outline,
        onTap: onTap,
      ),
    );
  }

  /// 预览区域
  Widget _buildPreviewArea(BarcodeTemplateEditorController controller) {
    return Center(
      child: Obx(() {
        final size = controller.labelSize.value;
        // 根据 DPI 转换: 203dpi 时 1mm = 8 dots
        final widthPx = size.width * 3; // 简化显示
        final heightPx = size.height * 3;

        return GestureDetector(
          onTap: controller.clearSelection,
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(50),
            minScale: 0.5,
            maxScale: 3,
            child: Container(
              width: widthPx,
              height: heightPx,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 网格背景
                  CustomPaint(
                    size: Size(widthPx, heightPx),
                    painter: _GridPainter(),
                  ),
                  
                  // 元素列表
                  ...controller.elements.map((element) => _buildElementWidget(
                    element,
                    controller,
                    scale: 3.0,
                  )),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 元素控件
  Widget _buildElementWidget(
    BarcodeElement element,
    BarcodeTemplateEditorController controller, {
    required double scale,
  }) {
    final isSelected = controller.selectedElementId.value == element.id;
    
    return Positioned(
      left: element.x * scale,
      top: element.y * scale,
      child: GestureDetector(
        onTap: () => controller.selectElement(element.id),
        onPanUpdate: (details) {
          controller.updateElementPosition(
            element.id,
            element.x + details.delta.dx / scale,
            element.y + details.delta.dy / scale,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: const Color(0xFF667eea), width: 2)
                : null,
          ),
          child: _buildElementContent(element, scale),
        ),
      ),
    );
  }

  Widget _buildElementContent(BarcodeElement element, double scale) {
    switch (element.type) {
      case BarcodeElementType.barcode:
        return Container(
          width: 100,
          height: 40,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.barcode_reader, size: 32),
          ),
        );
      case BarcodeElementType.qrcode:
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.qr_code, size: 40),
          ),
        );
      case BarcodeElementType.productName:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            '商品名称',
            style: TextStyle(fontSize: 12),
          ),
        );
      case BarcodeElementType.productSpec:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            '规格',
            style: TextStyle(fontSize: 10),
          ),
        );
      case BarcodeElementType.price:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            '¥价格',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        );
      case BarcodeElementType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            element.customText ?? '文本',
            style: TextStyle(
              fontSize: element.style.fontSize,
              fontWeight: element.style.isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      case BarcodeElementType.line:
        return Container(
          width: 100,
          height: 2,
          color: Colors.black,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 属性面板
  Widget _buildPropertyPanel(BarcodeTemplateEditorController controller) {
    return Obx(() {
      final selectedElement = controller.selectedElement;
      if (selectedElement == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedElement.type.displayName} 属性',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TDButton(
                  text: '删除',
                  theme: TDButtonTheme.danger,
                  size: TDButtonSize.small,
                  type: TDButtonType.outline,
                  onTap: () => controller.deleteElement(selectedElement.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 位置设置
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    'X 位置 (mm)',
                    selectedElement.x.toString(),
                    (value) => controller.updateElement(
                      selectedElement.copyWith(x: double.tryParse(value) ?? 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    'Y 位置 (mm)',
                    selectedElement.y.toString(),
                    (value) => controller.updateElement(
                      selectedElement.copyWith(y: double.tryParse(value) ?? 0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 文本内容（如果是文本元素）
            if (selectedElement.type == BarcodeElementType.text)
              TDInput(
                controller: TextEditingController(text: selectedElement.customText),
                leftLabel: '文本内容',
                hintText: '输入文本',
                onChanged: (value) => controller.updateElement(
                  selectedElement.copyWith(customText: value),
                ),
              ),
            
            if (selectedElement.type == BarcodeElementType.text)
              const SizedBox(height: 12),
            
            // 字体大小
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    '字体大小 (pt)',
                    selectedElement.style.fontSize.toString(),
                    (value) => controller.updateElement(
                      selectedElement.copyWith(
                        style: selectedElement.style.copyWith(
                          fontSize: double.tryParse(value) ?? 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TDCell(
                    title: '加粗',
                    rightIconWidget: selectedElement.style.isBold
                        ? Icon(Icons.check_box, color: Theme.of(Get.context!).primaryColor)
                        : const Icon(Icons.check_box_outline_blank),
                    onClick: (cell) => controller.updateElement(
                      selectedElement.copyWith(
                        style: selectedElement.style.copyWith(
                          isBold: !selectedElement.style.isBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNumberInput(String label, String value, Function(String) onChanged) {
    return TDInput(
      controller: TextEditingController(text: value),
      leftLabel: label,
      inputType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }

  /// 显示类型选择器
  void _showTypePicker(BarcodeTemplateEditorController controller) {
    final types = BarcodeTemplateType.values;
    
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择模版类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...types.map((type) => ListTile(
              title: Text(type.displayName),
              trailing: controller.selectedType.value == type
                  ? const Icon(Icons.check, color: Color(0xFF667eea))
                  : null,
              onTap: () {
                controller.onTypeChanged(type);
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  /// 显示尺寸选择器
  void _showSizePicker(BarcodeTemplateEditorController controller) {
    final sizes = BarcodeLabelSize.presets;
    
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择标签尺寸',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...sizes.map((size) {
              final isSelected = controller.labelSize.value.width == size.width &&
                  controller.labelSize.value.height == size.height;
              return ListTile(
                title: Text('${size.width}x${size.height}mm'),
                subtitle: size.columns != null
                    ? Text('${size.columns}x${size.rows} 排列')
                    : null,
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF667eea))
                    : null,
                onTap: () {
                  controller.onLabelSizeChanged(size);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 网格绘制器
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    const gridSize = 10.0;

    // 绘制水平线
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 绘制垂直线
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
