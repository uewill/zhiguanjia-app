import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/print_template_model.dart';
import '../controllers/print_template_controller.dart';

/// 打印模版管理列表页
class PrintTemplateListView extends GetView<PrintTemplateController> {
  const PrintTemplateListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PrintTemplateController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('打印模版'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.goToCreate,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildTemplateList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '', label: Text('全部')),
                ButtonSegment(value: 'receipt', label: Text('小票')),
                ButtonSegment(value: 'delivery', label: Text('发货单')),
                ButtonSegment(value: 'invoice', label: Text('发票')),
              ],
              selected: {controller.selectedType.value},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) {
                  controller.onTypeChanged(value.first);
                }
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredTemplates.isEmpty) {
        return _buildEmptyView();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredTemplates.length,
        itemBuilder: (context, index) {
          final template = controller.filteredTemplates[index];
          return _buildTemplateCard(template);
        },
      );
    });
  }

  Widget _buildTemplateCard(PrintTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：名称和状态
          ListTile(
            leading: _buildTypeIcon(template.type),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (template.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FC27D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '默认',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '${_getTypeText(template.type)} · ${template.paperSize.name}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Switch(
              value: template.isEnabled,
              onChanged: (_) => controller.toggleEnabled(template),
            ),
          ),

          // 描述
          if (template.description != null && template.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                template.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),

          // 元素统计
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.layers_outlined, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${template.elements.length} 个元素',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '更新于 ${_formatDate(template.updateTime)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),

          // 操作按钮
          const Divider(height: 1),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: '编辑',
                onTap: () => controller.goToEdit(template),
              ),
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: '预览',
                onTap: () => controller.previewTemplate(template),
              ),
              _buildActionButton(
                icon: Icons.star_outline,
                label: '设为默认',
                onTap: template.isDefault ? null : () => controller.setAsDefault(template),
                isEnabled: !template.isDefault,
              ),
              _buildActionButton(
                icon: Icons.delete_outline,
                label: '删除',
                onTap: template.isDefault ? null : () => controller.deleteTemplate(template),
                isEnabled: !template.isDefault,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    final iconData = switch (type) {
      'receipt' => Icons.receipt_outlined,
      'delivery' => Icons.local_shipping_outlined,
      'invoice' => Icons.description_outlined,
      _ => Icons.print_outlined,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2FC27D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: const Color(0xFF2FC27D)),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isEnabled = true,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              right: label != '删除'
                  ? BorderSide(color: Colors.grey[200]!)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isEnabled ? (color ?? Colors.grey[600]) : Colors.grey[300],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isEnabled ? (color ?? Colors.grey[600]) : Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.print_disabled_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无打印模版',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.goToCreate,
            child: const Text('创建模版'),
          ),
        ],
      ),
    );
  }

  String _getTypeText(String type) {
    return switch (type) {
      'receipt' => '小票',
      'delivery' => '发货单',
      'invoice' => '发票',
      _ => '其他',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
