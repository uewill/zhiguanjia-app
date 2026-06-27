import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../services/excel_service.dart';

class ExcelImportExportView extends StatelessWidget {
  const ExcelImportExportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final excelService = Get.isRegistered<ExcelService>()
        ? Get.find<ExcelService>()
        : Get.put(ExcelService());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '批量导入导出',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 商品导入导出
          _buildSectionCard(
            title: '商品管理',
            icon: Icons.inventory,
            color: Colors.blue,
            children: [
              _buildActionRow(
                title: '复制商品模板',
                subtitle: '用于批量导入商品',
                icon: Icons.content_copy,
                onTap: () {
                  final template = excelService.getProductTemplate();
                  Clipboard.setData(ClipboardData(text: template));
                  Get.snackbar('成功', '商品模板已复制到剪贴板');
                },
              ),
              const Divider(height: 1),
              _buildActionRow(
                title: '导出商品',
                subtitle: '导出所有商品数据',
                icon: Icons.download,
                onTap: () async {
                  final data = await excelService.exportProducts();
                  Clipboard.setData(ClipboardData(text: data));
                  Get.snackbar('成功', '商品数据已复制到剪贴板');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 客户导入导出
          _buildSectionCard(
            title: '客户管理',
            icon: Icons.people,
            color: Colors.purple,
            children: [
              _buildActionRow(
                title: '复制客户模板',
                subtitle: '用于批量导入客户',
                icon: Icons.content_copy,
                onTap: () {
                  final template = excelService.getCustomerTemplate();
                  Clipboard.setData(ClipboardData(text: template));
                  Get.snackbar('成功', '客户模板已复制到剪贴板');
                },
              ),
              const Divider(height: 1),
              _buildActionRow(
                title: '导出客户',
                subtitle: '导出所有客户数据',
                icon: Icons.download,
                onTap: () async {
                  final data = await excelService.exportCustomers();
                  Clipboard.setData(ClipboardData(text: data));
                  Get.snackbar('成功', '客户数据已复制到剪贴板');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 供应商导入导出
          _buildSectionCard(
            title: '供应商管理',
            icon: Icons.business,
            color: Colors.orange,
            children: [
              _buildActionRow(
                title: '复制供应商模板',
                subtitle: '用于批量导入供应商',
                icon: Icons.content_copy,
                onTap: () {
                  final template = excelService.getSupplierTemplate();
                  Clipboard.setData(ClipboardData(text: template));
                  Get.snackbar('成功', '供应商模板已复制到剪贴板');
                },
              ),
              const Divider(height: 1),
              _buildActionRow(
                title: '导出供应商',
                subtitle: '导出所有供应商数据',
                icon: Icons.download,
                onTap: () async {
                  final data = await excelService.exportSuppliers();
                  Clipboard.setData(ClipboardData(text: data));
                  Get.snackbar('成功', '供应商数据已复制到剪贴板');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 使用说明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('使用说明', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. 复制模板到Excel中填写数据\n2. 将填好的数据复制为CSV格式\n3. 粘贴数据导入系统',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                TDText(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2FC27D)),
      title: TDText(title),
      subtitle: TDText(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
