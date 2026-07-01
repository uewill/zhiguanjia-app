import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/barcode_template_model.dart';
import '../controllers/barcode_template_controller.dart';

/// 条码模版列表页面
class BarcodeTemplateListView extends StatelessWidget {
  const BarcodeTemplateListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<BarcodeTemplateController>()
        ? Get.find<BarcodeTemplateController>()
        : Get.put(BarcodeTemplateController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('条码模版管理'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 类型筛选
          _buildTypeFilter(controller),
          
          // 模版列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredTemplates.isEmpty) {
                return _buildEmptyState(controller);
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = controller.filteredTemplates[index];
                  return _buildTemplateCard(controller, template);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToCreate,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 类型筛选栏
  Widget _buildTypeFilter(BarcodeTemplateController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: BarcodeTemplateType.values.map((type) {
            final isSelected = controller.selectedType.value == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) => controller.onTypeChanged(type),
                selectedColor: const Color(0xFF667eea),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState(BarcodeTemplateController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无条码模版',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建新模版',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 模版卡片
  Widget _buildTemplateCard(BarcodeTemplateController controller, BarcodeTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => controller.goToEdit(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 预览缩略图
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Icon(
                        _getTypeIcon(template.type),
                        size: 24,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 模版信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (template.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '默认',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF667eea),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${template.labelSize.width}x${template.labelSize.height}mm · ${template.elements.length}个元素',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 操作按钮
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'preview':
                          controller.previewTemplate(template);
                          break;
                        case 'edit':
                          controller.goToEdit(template);
                          break;
                        case 'delete':
                          controller.deleteTemplate(template);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            Icon(Icons.preview, size: 18),
                            SizedBox(width: 8),
                            Text('预览'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red.shade400),
                            const SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red.shade400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (template.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  template.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(BarcodeTemplateType type) {
    switch (type) {
      case BarcodeTemplateType.single:
        return Icons.barcode_reader;
      case BarcodeTemplateType.sheet:
        return Icons.grid_on;
      case BarcodeTemplateType.priceTag:
        return Icons.local_offer;
      case BarcodeTemplateType.shelfTag:
        return Icons.shelves;
    }
  }
}
