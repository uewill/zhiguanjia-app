import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../services/print_service.dart';
import '../controllers/print_template_controller.dart';

/// PDF打印预览页面
class PrintPreviewView extends StatefulWidget {
  const PrintPreviewView({Key? key}) : super(key: key);

  @override
  State<PrintPreviewView> createState() => _PrintPreviewViewState();
}

class _PrintPreviewViewState extends State<PrintPreviewView> {
  late final PrintService _printService;
  final args = Get.arguments as Map<String, dynamic>;

  late String pdfUrl;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _printService = Get.isRegistered<PrintService>()
        ? Get.find<PrintService>()
        : Get.put(PrintService());
    pdfUrl = args['pdfUrl'] as String;
    // 模拟加载
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打印预览'),
        actions: [
          TextButton.icon(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('下载', style: TextStyle(color: Colors.white)),
          ),
          TextButton.icon(
            onPressed: _printPdf,
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text('打印', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('加载失败: $error'))
              : _buildPdfPreview(),
    );
  }

  Widget _buildPdfPreview() {
    // 使用WebView或图片预览PDF
    // 这里使用简单的占位显示
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 120, color: Colors.red[300]),
          const SizedBox(height: 24),
          const Text(
            'PDF 文件已生成',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'PDF URL: ${pdfUrl.substring(0, pdfUrl.length > 50 ? 50 : pdfUrl.length)}...',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _printPdf,
                icon: const Icon(Icons.print),
                label: const Text('打印文档'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC27D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _sharePdf,
                icon: const Icon(Icons.share),
                label: const Text('分享'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _downloadPdf() {
    if (Get.context != null) {
      TDToast.showText('开始下载PDF...', context: Get.context!);
    }
    // 调用下载逻辑
  }

  void _printPdf() {
    if (Get.context != null) {
      TDToast.showText('调用系统打印...', context: Get.context!);
    }
    // 调用打印逻辑
  }

  void _sharePdf() {
    if (Get.context != null) {
      TDToast.showText('分享PDF...', context: Get.context!);
    }
    // 调用分享逻辑
  }
}

/// 打印设置页面
class PrintSettingsView extends StatelessWidget {
  const PrintSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('打印设置')),
      body: ListView(
        children: [
          // 打印机设置
          const ListTile(
            title: Text('打印机连接', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('蓝牙打印机'),
            subtitle: const Text('未连接'),
            trailing: TextButton(
              onPressed: () {
                // 打开蓝牙搜索
              },
              child: const Text('连接'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('网络打印机'),
            subtitle: const Text('未配置'),
            trailing: TextButton(
              onPressed: () {
                // 打开网络打印机配置
              },
              child: const Text('配置'),
            ),
          ),

          const Divider(),

          // 打印模版
          const ListTile(
            title: Text('打印模版', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('小票模版'),
            subtitle: const Text('管理小票打印格式'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed('/print/templates', arguments: {'type': 'receipt'}),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('发货单模版'),
            subtitle: const Text('管理发货单打印格式'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed('/print/templates', arguments: {'type': 'delivery'}),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('发票模版'),
            subtitle: const Text('管理发票打印格式'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed('/print/templates', arguments: {'type': 'invoice'}),
          ),

          const Divider(),

          // 默认设置
          const ListTile(
            title: Text('默认设置', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('自动打印小票'),
            subtitle: const Text('销售完成后自动打印'),
            value: false,
            onChanged: (value) {
              // 保存设置
            },
          ),
          SwitchListTile(
            title: const Text('打印后自动切纸'),
            subtitle: const Text('热敏打印机自动切纸'),
            value: true,
            onChanged: (value) {
              // 保存设置
            },
          ),

          const Divider(),

          // 打印历史
          const ListTile(
            title: Text('打印历史', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('查看打印记录'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed('/print/history'),
          ),
        ],
      ),
    );
  }
}
