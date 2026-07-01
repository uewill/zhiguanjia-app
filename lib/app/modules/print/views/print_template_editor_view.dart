import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/print_template_model.dart';
import '../controllers/print_template_controller.dart';

/// 打印模版编辑器页面
class PrintTemplateEditorView extends GetView<PrintTemplateEditorController> {
  const PrintTemplateEditorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PrintTemplateEditorController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑打印模版'),
        actions: [
          TextButton(
            onPressed: controller.preview,
            child: const Text('预览', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: controller.isSaving.value ? null : controller.saveTemplate,
            child: Obx(() => controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('保存', style: TextStyle(color: Colors.white))),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // 左侧：模版设置
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[50],
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('模版设置'),
                    _buildBasicSettings(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('添加元素'),
                    _buildElementToolbox(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('快速模板'),
                    _buildQuickTemplates(),
                  ],
                ),
              ),
            ),
          ),

          // 中间：预览画布
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Center(child: _buildCanvas()),
            ),
          ),

          // 右侧：属性编辑
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[50],
              child: _buildPropertyPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Obx(() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: '模版名称',
                hintText: '输入模版名称',
              ),
              onChanged: controller.onNameChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descController,
              decoration: const InputDecoration(
                labelText: '模版描述',
                hintText: '输入模版描述（可选）',
              ),
              onChanged: controller.onDescriptionChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: controller.template.value.type,
              decoration: const InputDecoration(labelText: '模版类型'),
              items: const [
                DropdownMenuItem(value: 'receipt', child: Text('小票')),
                DropdownMenuItem(value: 'delivery', child: Text('发货单')),
                DropdownMenuItem(value: 'invoice', child: Text('发票')),
              ],
              onChanged: controller.onTypeChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaperSize>(
              value: controller.template.value.paperSize,
              decoration: const InputDecoration(labelText: '纸张尺寸'),
              items: [
                DropdownMenuItem(value: PaperSize.mm58, child: Text('58mm 热敏纸')),
                DropdownMenuItem(value: PaperSize.mm80, child: Text('80mm 热敏纸')),
                DropdownMenuItem(value: PaperSize.a5, child: Text('A5 发货单')),
                DropdownMenuItem(value: PaperSize.a4, child: Text('A4 发票')),
              ],
              onChanged: controller.onPaperSizeChanged,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildElementToolbox() {
    final elements = [
      _ToolboxItem(icon: Icons.title, label: '文本', type: 'text'),
      _ToolboxItem(icon: Icons.image, label: '图片', type: 'image'),
      _ToolboxItem(icon: Icons.qr_code, label: '二维码', type: 'qrcode'),
      _ToolboxItem(icon: Icons.barcode_reader, label: '条形码', type: 'barcode'),
      _ToolboxItem(icon: Icons.horizontal_rule, label: '分隔线', type: 'line'),
      _ToolboxItem(icon: Icons.table_chart, label: '表格', type: 'table'),
      _ToolboxItem(icon: Icons.space_bar, label: '空行', type: 'space'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: elements.map((item) => _buildToolboxButton(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildToolboxButton(_ToolboxItem item) {
    return InkWell(
      onTap: () => controller.addElement(item.type),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 24, color: const Color(0xFF2FC27D)),
            const SizedBox(height: 4),
            Text(item.label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTemplates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('快速小票'),
              subtitle: const Text('包含常见小票元素'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: controller.addReceiptElements,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('发货单'),
              subtitle: const Text('包含客户和商品信息'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 添加发货单元素
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return Obx(() {
      final paperSize = controller.template.value.paperSize;
      final isContinuous = paperSize.height == 0;

      // 计算画布尺寸（像素转换：1mm ≈ 3.78px at 96dpi）
      const pxPerMm = 3.78;
      final width = paperSize.width * pxPerMm;
      final height = isContinuous ? 600.0 : paperSize.height * pxPerMm;

      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.template.value.elements.length,
          onReorder: controller.moveElement,
          itemBuilder: (context, index) {
            final element = controller.template.value.elements[index];
            return _buildCanvasElement(element, index);
          },
        ),
      );
    });
  }

  Widget _buildCanvasElement(PrintElement element, int index) {
    return Obx(() {
      final isSelected = controller.selectedElementId.value == element.id;

      return GestureDetector(
        onTap: () => controller.selectElement(element.id),
        child: Container(
          key: ValueKey(element.id),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF2FC27D) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: isSelected ? const Color(0xFF2FC27D).withValues(alpha: 0.05) : null,
          ),
          child: Row(
            children: [
              // 拖拽手柄
              Icon(Icons.drag_handle, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),

              // 元素内容预览
              Expanded(child: _buildElementPreview(element)),

              // 删除按钮
              if (isSelected)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  onPressed: () => controller.deleteElement(element.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildElementPreview(PrintElement element) {
    final style = element.style;

    switch (element.type) {
      case 'text':
        return Text(
          element.customText ?? element.field ?? '文本元素',
          style: TextStyle(
            fontSize: style.fontSize,
            fontWeight: style.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: style.isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: style.isUnderline ? TextDecoration.underline : null,
          ),
          textAlign: _getTextAlign(style.align),
        );

      case 'line':
        return Container(
          height: 1,
          color: Colors.black,
          margin: const EdgeInsets.symmetric(vertical: 8),
        );

      case 'table':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('商品列表表格', style: TextStyle(fontSize: 12)),
        );

      case 'qrcode':
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.qr_code, size: 40),
        );

      case 'barcode':
        return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(child: Text('||| || ||| ||', style: TextStyle(fontSize: 20))),
        );

      case 'space':
        return Container(height: 16, color: Colors.grey[100]);

      default:
        return Text('${element.type} 元素');
    }
  }

  Widget _buildPropertyPanel() {
    return Obx(() {
      final element = controller.selectedElement;

      if (element == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                '点击画布中的元素进行编辑',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('元素属性'),
            _buildElementProperties(element),
          ],
        ),
      );
    });
  }

  Widget _buildElementProperties(PrintElement element) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 元素类型
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('元素类型'),
              subtitle: Text(_getElementTypeText(element.type)),
            ),

            // 文本内容（文本类型）
            if (element.type == 'text')
              TextField(
                decoration: const InputDecoration(
                  labelText: '自定义文本',
                  hintText: '空表示使用字段值',
                ),
                controller: TextEditingController(text: element.customText),
                onChanged: (value) {
                  controller.updateElement(element.copyWith(customText: value));
                },
              ),

            // 字段选择
            if (['text', 'table', 'qrcode', 'barcode'].contains(element.type))
              DropdownButtonFormField<String>(
                value: element.field,
                decoration: const InputDecoration(labelText: '数据字段'),
                hint: const Text('选择数据字段'),
                items: _buildFieldItems(element.type),
                onChanged: (value) {
                  controller.updateElement(element.copyWith(field: value));
                },
              ),

            const Divider(),

            // 样式设置
            const Text('样式设置', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // 字号
            Row(
              children: [
                const Text('字号:'),
                Expanded(
                  child: Slider(
                    value: element.style.fontSize,
                    min: 8,
                    max: 24,
                    divisions: 16,
                    label: element.style.fontSize.toStringAsFixed(0),
                    onChanged: (value) {
                      controller.updateElement(
                        element.copyWith(style: element.style.copyWith(fontSize: value)),
                      );
                    },
                  ),
                ),
                Text('${element.style.fontSize.toInt()}pt'),
              ],
            ),

            // 对齐方式
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'left', label: Text('左')),
                ButtonSegment(value: 'center', label: Text('中')),
                ButtonSegment(value: 'right', label: Text('右')),
              ],
              selected: {element.style.align},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) {
                  controller.updateElement(
                    element.copyWith(style: element.style.copyWith(align: value.first)),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // 样式开关
            Row(
              children: [
                FilterChip(
                  label: const Text('粗体'),
                  selected: element.style.isBold,
                  onSelected: (value) {
                    controller.updateElement(
                      element.copyWith(style: element.style.copyWith(isBold: value)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('斜体'),
                  selected: element.style.isItalic,
                  onSelected: (value) {
                    controller.updateElement(
                      element.copyWith(style: element.style.copyWith(isItalic: value)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('下划线'),
                  selected: element.style.isUnderline,
                  onSelected: (value) {
                    controller.updateElement(
                      element.copyWith(style: element.style.copyWith(isUnderline: value)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildFieldItems(String elementType) {
    if (elementType == 'table') {
      return const [
        DropdownMenuItem(value: PrintFields.itemsTable, child: Text('商品列表')),
      ];
    }

    if (elementType == 'qrcode') {
      return const [
        DropdownMenuItem(value: PrintFields.orderNo, child: Text('订单号')),
        DropdownMenuItem(value: PrintFields.shopLogo, child: Text('店铺Logo')),
      ];
    }

    if (elementType == 'barcode') {
      return const [
        DropdownMenuItem(value: PrintFields.orderNo, child: Text('订单号')),
      ];
    }

    // 文本字段
    return const [
      DropdownMenuItem(value: PrintFields.shopName, child: Text('店铺名称')),
      DropdownMenuItem(value: PrintFields.shopAddress, child: Text('店铺地址')),
      DropdownMenuItem(value: PrintFields.shopPhone, child: Text('店铺电话')),
      DropdownMenuItem(value: PrintFields.orderNo, child: Text('订单号')),
      DropdownMenuItem(value: PrintFields.orderTime, child: Text('订单时间')),
      DropdownMenuItem(value: PrintFields.totalQuantity, child: Text('总数量')),
      DropdownMenuItem(value: PrintFields.totalAmount, child: Text('总金额')),
      DropdownMenuItem(value: PrintFields.payableAmount, child: Text('应付金额')),
      DropdownMenuItem(value: PrintFields.paymentMethod, child: Text('支付方式')),
      DropdownMenuItem(value: PrintFields.customerName, child: Text('客户名称')),
      DropdownMenuItem(value: PrintFields.customerPhone, child: Text('客户电话')),
      DropdownMenuItem(value: PrintFields.customerAddress, child: Text('客户地址')),
      DropdownMenuItem(value: PrintFields.remark, child: Text('备注')),
      DropdownMenuItem(value: PrintFields.printTime, child: Text('打印时间')),
      DropdownMenuItem(value: PrintFields.cashierName, child: Text('收银员')),
    ];
  }

  TextAlign _getTextAlign(String align) {
    return switch (align) {
      'center' => TextAlign.center,
      'right' => TextAlign.right,
      _ => TextAlign.left,
    };
  }

  String _getElementTypeText(String type) {
    return switch (type) {
      'text' => '文本',
      'image' => '图片',
      'qrcode' => '二维码',
      'barcode' => '条形码',
      'line' => '分隔线',
      'table' => '表格',
      'space' => '空行',
      _ => type,
    };
  }
}

class _ToolboxItem {
  final IconData icon;
  final String label;
  final String type;

  _ToolboxItem({required this.icon, required this.label, required this.type});
}
