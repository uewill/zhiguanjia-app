import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/barcode_template_model.dart';
import '../../../services/barcode_print_service.dart';

/// 条码打印页面 - 用于商品管理和单据打印
/// 注：蓝牙功能暂时注释，需要时请在 pubspec.yaml 中启用 flutter_bluetooth_serial
class BarcodePrintView extends StatelessWidget {
  const BarcodePrintView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BarcodePrintController());
    final args = Get.arguments as Map<String, dynamic>?;
    
    // 如果从商品页面进入，传入商品数据
    if (args != null && args.containsKey('product')) {
      controller.setProduct(args['product']);
    }
    // 如果从单据进入，传入商品列表
    if (args != null && args.containsKey('products')) {
      controller.setProducts(args['products']);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('条码打印'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 打印机状态
          _buildPrinterStatus(controller),
          
          // 产品信息
          _buildProductInfo(controller),
          
          // 模版选择
          _buildTemplateSelector(controller),
          
          // 打印设置
          _buildPrintSettings(controller),
          
          const Spacer(),
          
          // 打印按钮
          _buildPrintButton(controller),
        ],
      ),
    );
  }

  /// 打印机状态卡
  Widget _buildPrinterStatus(BarcodePrintController controller) {
    return Obx(() {
      final isConnected = controller.barcodeService.isConnected.value;
      final device = controller.barcodeService.connectedDevice.value;
      
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? '打印机已连接' : '打印机未连接',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                  if (device != null)
                    Text(
                      device.name ?? device.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                ],
              ),
            ),
            TDButton(
              text: isConnected ? '切换' : '连接',
              size: TDButtonSize.small,
              type: TDButtonType.outline,
              onTap: () => _showDeviceSelector(controller),
            ),
          ],
        ),
      );
    });
  }

  /// 产品信息区域
  Widget _buildProductInfo(BarcodePrintController controller) {
    return Obx(() {
      final product = controller.selectedProduct.value;
      if (product == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? '商品名称',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '条码: ${product['barcode'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '售价: ¥${product['salePrice']?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// 模版选择器
  Widget _buildTemplateSelector(BarcodePrintController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '打印模版',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => TDCell(
            title: controller.selectedTemplate.value?.name ?? '选择模版',
            note: controller.selectedTemplate.value != null
                ? '${controller.selectedTemplate.value!.labelSize.width}x${controller.selectedTemplate.value!.labelSize.height}mm'
                : '',
            arrow: true,
            onClick: (cell) => _showTemplatePicker(controller),
          )),
          const SizedBox(height: 12),
          // 预览图
          Obx(() {
            final template = controller.selectedTemplate.value;
            if (template == null) return const SizedBox.shrink();
            
            return Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildTemplatePreview(template),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview(BarcodeTemplate template) {
    final scale = 3.0;
    final width = template.labelSize.width * scale;
    final height = template.labelSize.height * scale;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: template.elements.map((e) {
          return Positioned(
            left: e.x * scale,
            top: e.y * scale,
            child: _buildPreviewElement(e),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreviewElement(BarcodeElement element) {
    switch (element.type) {
      case BarcodeElementType.barcode:
        return Container(
          width: 80,
          height: 30,
          color: Colors.grey.shade200,
          child: const Icon(Icons.barcode_reader, size: 24),
        );
      case BarcodeElementType.qrcode:
        return Container(
          width: 40,
          height: 40,
          color: Colors.grey.shade200,
          child: const Icon(Icons.qr_code, size: 28),
        );
      case BarcodeElementType.productName:
        return Container(
          padding: const EdgeInsets.all(2),
          color: Colors.blue.shade50,
          child: const Text('名称', style: TextStyle(fontSize: 8)),
        );
      case BarcodeElementType.productSpec:
        return Container(
          padding: const EdgeInsets.all(2),
          color: Colors.green.shade50,
          child: const Text('规格', style: TextStyle(fontSize: 7)),
        );
      case BarcodeElementType.price:
        return Container(
          padding: const EdgeInsets.all(2),
          color: Colors.orange.shade50,
          child: const Text('¥0.00', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 打印设置
  Widget _buildPrintSettings(BarcodePrintController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '打印设置',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => TDStepper(
            value: controller.copies.value,
            min: 1,
            max: 100,
            step: 1,
            onChange: (value) => controller.copies.value = value.toInt(),
          )),
        ],
      ),
    );
  }

  /// 打印按钮
  Widget _buildPrintButton(BarcodePrintController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => TDButton(
          text: controller.isPrinting.value ? '打印中...' : '🖨️ 开始打印',
          size: TDButtonSize.large,
          theme: TDButtonTheme.primary,
          isBlock: true,
          disabled: controller.isPrinting.value || !controller.canPrint.value,
          onTap: controller.printBarcode,
        )),
      ),
    );
  }

  /// 显示设备选择器
  void _showDeviceSelector(BarcodePrintController controller) {
    controller.scanDevices();
    
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择打印机',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => controller.barcodeService.isScanning.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
            const Divider(height: 1),
            Obx(() {
              final devices = controller.barcodeService.discoveredDevices;
              if (devices.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('未发现打印机，请确保打印机已开机并进入配对模式'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final isConnected = controller.barcodeService.connectedDevice.value?.address == device.address;
                  
                  return ListTile(
                    leading: Icon(
                      Icons.print,
                      color: isConnected ? const Color(0xFF667eea) : Colors.grey,
                    ),
                    title: Text(device.name ?? '未知设备'),
                    subtitle: Text(device.address),
                    trailing: isConnected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      controller.connectDevice(device);
                      Get.back();
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// 显示模版选择器
  void _showTemplatePicker(BarcodePrintController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '选择打印模版',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.templates.length,
              itemBuilder: (context, index) {
                final template = controller.templates[index];
                final isSelected = controller.selectedTemplate.value?.id == template.id;
                
                return ListTile(
                  title: Text(template.name),
                  subtitle: Text('${template.labelSize.width}x${template.labelSize.height}mm'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF667eea))
                      : null,
                  onTap: () {
                    controller.selectedTemplate.value = template;
                    Get.back();
                  },
                );
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

/// 条码打印控制器
class BarcodePrintController extends GetxController {
  late final BarcodePrintService barcodeService;

  // 商品数据
  final selectedProduct = Rx<Map<String, dynamic>?>(null);
  final products = <Map<String, dynamic>>[].obs;

  // 模版
  final templates = <BarcodeTemplate>[].obs;
  final selectedTemplate = Rx<BarcodeTemplate?>(null);

  // 打印设置
  final copies = 1.obs;
  final isPrinting = false.obs;

  // 是否可打印
  final canPrint = false.obs;

  @override
  void onInit() {
    super.onInit();
    barcodeService = Get.isRegistered<BarcodePrintService>()
        ? Get.find<BarcodePrintService>()
        : Get.put(BarcodePrintService());
    _loadTemplates();
    
    // 监听状态变化
    ever(selectedProduct, (_) => _updateCanPrint());
    ever(selectedTemplate, (_) => _updateCanPrint());
    ever(barcodeService.isConnected, (_) => _updateCanPrint());
  }

  void _updateCanPrint() {
    canPrint.value = selectedProduct.value != null &&
        selectedTemplate.value != null &&
        barcodeService.isConnected.value;
  }

  Future<void> _loadTemplates() async {
    templates.value = await barcodeService.getTemplates();
    // 默认选中第一个
    if (templates.isNotEmpty) {
      selectedTemplate.value = templates.firstWhere(
        (t) => t.isDefault,
        orElse: () => templates.first,
      );
    }
  }

  void setProduct(Map<String, dynamic> product) {
    selectedProduct.value = product;
  }

  void setProducts(List<Map<String, dynamic>> productList) {
    products.value = productList;
    if (productList.isNotEmpty) {
      selectedProduct.value = productList.first;
    }
  }

  void scanDevices() {
    barcodeService.startScan();
  }

  Future<void> connectDevice(dynamic device) async {
    final success = await barcodeService.connectDevice(device);
    if (success) {
      TDToast.showText('连接成功', context: Get.context!);
    } else {
      TDToast.showText('连接失败', context: Get.context!);
    }
  }

  Future<void> printBarcode() async {
    if (!canPrint.value) return;

    isPrinting.value = true;
    try {
      final success = await barcodeService.printBarcode(
        template: selectedTemplate.value!,
        productData: selectedProduct.value!,
        copies: copies.value,
      );

      if (success) {
        TDToast.showText('打印指令已发送', context: Get.context!);
      } else {
        TDToast.showText('打印失败', context: Get.context!);
      }
    } catch (e) {
      TDToast.showText('打印错误: $e', context: Get.context!);
    } finally {
      isPrinting.value = false;
    }
  }
}
