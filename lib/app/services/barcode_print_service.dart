import 'dart:async';
import 'dart:typed_data';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import '../data/models/barcode_template_model.dart';
import 'printer_command_service.dart';

/// 条码打印服务 - 支持蓝牙条码打印机
/// 注意：蓝牙功能暂时注释，如需启用请取消 pubspec.yaml 中的 flutter_bluetooth_serial 依赖
class BarcodePrintService extends GetxService {
  // final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // 蓝牙连接状态
  final isScanning = false.obs;
  final isConnected = false.obs;
  // final connectedDevice = Rx<BluetoothDevice?>(null);
  // final discoveredDevices = <BluetoothDevice>[].obs;
  final connectedDevice = Rx<dynamic>(null);
  final discoveredDevices = <dynamic>[].obs;

  // BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _dataSubscription;

  // ========== 蓝牙设备管理 ==========

  /// 开始扫描蓝牙设备
  Future<void> startScan() async {
    Get.snackbar('提示', '蓝牙打印功能暂未启用，请在 pubspec.yaml 中启用 flutter_bluetooth_serial');
    return;
    /*
    try {
      isScanning.value = true;
      discoveredDevices.clear();

      // 检查蓝牙权限
      bool? isEnabled = await _bluetooth.isEnabled;
      if (isEnabled != true) {
        await _bluetooth.requestEnable();
      }

      // 获取已配对设备
      final bonded = await _bluetooth.getBondedDevices();
      discoveredDevices.addAll(bonded.where((d) => d.name?.contains('Printer') == true
          || d.name?.contains('打印') == true
          || d.name?.contains('TSC') == true
          || d.name?.contains('XPrinter') == true));

      // 开始发现设备
      _bluetooth.startDiscovery().listen((result) {
        if (!discoveredDevices.any((d) => d.address == result.device.address)) {
          discoveredDevices.add(result.device);
        }
      });

    } catch (e) {
      print('扫描蓝牙设备失败: $e');
    } finally {
      isScanning.value = false;
    }
    */
  }

  /// 停止扫描
  Future<void> stopScan() async {
    isScanning.value = false;
    // await _bluetooth.cancelDiscovery();
  }

  /// 连接设备
  Future<bool> connectDevice(dynamic device) async {
    Get.snackbar('提示', '蓝牙打印功能暂未启用');
    return false;
    /*
    try {
      // 断开现有连接
      await disconnect();

      // 建立连接
      final connection = await BluetoothConnection.toAddress(device.address);
      _connection = connection;

      if (connection.isConnected) {
        connectedDevice.value = device;
        isConnected.value = true;

        // 监听数据
        _dataSubscription = connection.input?.listen((data) {
          print('收到打印机响应: $data');
        });

        return true;
      }
    } catch (e) {
      print('连接设备失败: $e');
    }
    return false;
    */
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _dataSubscription?.cancel();
    _dataSubscription = null;
    // await _connection?.close();
    // _connection = null;
    connectedDevice.value = null;
    isConnected.value = false;
  }

  // ========== 条码打印 ==========

  /// 打印单个商品条码 (使用模版)
  Future<bool> printBarcode({
    required BarcodeTemplate template,
    required Map<String, dynamic> productData,
    int copies = 1,
  }) async {
    if (!isConnected.value) {
      Get.snackbar('提示', '蓝牙打印功能暂未启用');
      return false;
    }
    return false;
  }

  /// 打印条码页 (多个商品)
  Future<bool> printBarcodeSheet({
    required BarcodeTemplate template,
    required List<Map<String, dynamic>> products,
  }) async {
    if (!isConnected.value) {
      Get.snackbar('提示', '蓝牙打印功能暂未启用');
      return false;
    }
    return false;
  }

  /// 快速打印商品条码 (无需模版)
  Future<bool> quickPrintBarcode({
    required String barcode,
    required String productName,
    String? spec,
    double? price,
    int copies = 1,
  }) async {
    if (!isConnected.value) {
      Get.snackbar('提示', '蓝牙打印功能暂未启用');
      return false;
    }
    return false;
  }

  /// 根据模版生成条码 TSPL 指令
  String _generateSingleBarcodeFromTemplate({
    required BarcodeTemplate template,
    required Map<String, dynamic> product,
  }) {
    final sb = StringBuffer();

    // 初始化
    sb.write(PrinterCommandService.tsplInit());
    sb.write(PrinterCommandService.tsplSize(
      template.labelSize.width.toInt(),
      template.labelSize.height.toInt(),
    ));
    sb.write(PrinterCommandService.tsplDirection(0));

    // 遍历元素
    for (var element in template.elements) {
      final content = _getElementContent(element, product);

      switch (element.type) {
        case BarcodeElementType.barcode:
          sb.write(PrinterCommandService.tsplBarcode(
            _mmToDots(element.x),
            _mmToDots(element.y),
            content,
            height: _mmToDots(element.style.height > 0 ? element.style.height : 10),
            rotation: element.style.rotation,
          ));
          break;
        case BarcodeElementType.qrcode:
          sb.write(PrinterCommandService.tsplQRCode(
            _mmToDots(element.x),
            _mmToDots(element.y),
            content,
            rotation: element.style.rotation,
          ));
          break;
        case BarcodeElementType.text:
        case BarcodeElementType.productName:
        case BarcodeElementType.productSpec:
        case BarcodeElementType.price:
          final fontSize = element.style.fontSize > 12 ? 'TSS24.BF2' : 'TSS16.BF2';
          final scale = element.style.fontSize > 16 ? 2 : 1;
          sb.write(PrinterCommandService.tsplText(
            _mmToDots(element.x),
            _mmToDots(element.y),
            content,
            font: fontSize,
            xScale: scale,
            yScale: scale,
            rotation: element.style.rotation,
          ));
          break;
        case BarcodeElementType.line:
          // TSPL 不直接支持线条，用 BARCODE 或 BITMAP 模拟
          break;
        case BarcodeElementType.box:
          // 使用 BITMAP 或多条 BARCODE 模拟边框
          break;
        case BarcodeElementType.logo:
          // Logo 需要预先下载图片
          break;
      }
    }

    sb.write(PrinterCommandService.tsplPrint(1));
    sb.write(PrinterCommandService.tsplEnd());

    return sb.toString();
  }

  /// 获取元素内容
  String _getElementContent(BarcodeElement element, Map<String, dynamic> product) {
    if (element.customText != null && element.customText!.isNotEmpty) {
      return element.customText!;
    }

    switch (element.type) {
      case BarcodeElementType.barcode:
        return product['barcode']?.toString() ?? '';
      case BarcodeElementType.productName:
        return product['name']?.toString() ?? '';
      case BarcodeElementType.productSpec:
        return product['spec']?.toString() ?? '';
      case BarcodeElementType.price:
        final price = product['salePrice'] ?? product['price'];
        if (price != null) {
          return '¥${price.toStringAsFixed(2)}';
        }
        return '';
      case BarcodeElementType.qrcode:
        // 二维码内容可以是商品ID或URL
        return product['id']?.toString() ?? product['barcode']?.toString() ?? '';
      default:
        return element.customText ?? '';
    }
  }

  /// mm 转点 (203dpi: 1mm = 8 dots)
  int _mmToDots(double mm) {
    return (mm * 8).round();
  }

  // ========== 模版管理 ==========

  /// 获取条码模版列表
  Future<List<BarcodeTemplate>> getTemplates({BarcodeTemplateType? type}) async {
    // TODO: 从 API 获取
    return _getDefaultTemplates();
  }

  /// 保存模版
  Future<bool> saveTemplate(BarcodeTemplate template) async {
    // TODO: 调用 API
    return true;
  }

  /// 获取默认条码模版
  List<BarcodeTemplate> _getDefaultTemplates() {
    return [
      // 标准条码 - 40x30
      BarcodeTemplate(
        id: 'default_barcode_40x30',
        name: '标准条码 (40x30)',
        type: BarcodeTemplateType.single,
        description: '标准40x30mm条码标签',
        labelSize: BarcodeLabelSize.standard40x30,
        elements: [
          BarcodeElement(
            id: 'name',
            type: BarcodeElementType.productName,
            x: 2,
            y: 2,
            style: BarcodeElementStyle(fontSize: 10),
          ),
          BarcodeElement(
            id: 'barcode',
            type: BarcodeElementType.barcode,
            x: 2,
            y: 8,
            style: BarcodeElementStyle(height: 12),
          ),
          BarcodeElement(
            id: 'price',
            type: BarcodeElementType.price,
            x: 25,
            y: 22,
            style: BarcodeElementStyle(fontSize: 14, isBold: true),
          ),
        ],
        isDefault: true,
        isEnabled: true,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      // 价格标签 - 50x30
      BarcodeTemplate(
        id: 'default_price_tag',
        name: '价格标签 (50x30)',
        type: BarcodeTemplateType.priceTag,
        description: '商品价格标签',
        labelSize: BarcodeLabelSize.standard50x30,
        elements: [
          BarcodeElement(
            id: 'name',
            type: BarcodeElementType.productName,
            x: 2,
            y: 2,
            style: BarcodeElementStyle(fontSize: 12),
          ),
          BarcodeElement(
            id: 'spec',
            type: BarcodeElementType.productSpec,
            x: 2,
            y: 8,
            style: BarcodeElementStyle(fontSize: 9),
          ),
          BarcodeElement(
            id: 'barcode',
            type: BarcodeElementType.barcode,
            x: 2,
            y: 14,
            style: BarcodeElementStyle(height: 10),
          ),
          BarcodeElement(
            id: 'price',
            type: BarcodeElementType.price,
            x: 35,
            y: 20,
            style: BarcodeElementStyle(fontSize: 16, isBold: true),
          ),
        ],
        isDefault: false,
        isEnabled: true,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      // 多排条码页 - A4
      BarcodeTemplate(
        id: 'default_sheet_2x5',
        name: 'A4条码页 (2x5)',
        type: BarcodeTemplateType.sheet,
        description: 'A4纸打印，每页2列5行',
        labelSize: BarcodeLabelSize.a4Sheet2x5,
        elements: [
          BarcodeElement(
            id: 'name',
            type: BarcodeElementType.productName,
            x: 2,
            y: 2,
            style: BarcodeElementStyle(fontSize: 9),
          ),
          BarcodeElement(
            id: 'barcode',
            type: BarcodeElementType.barcode,
            x: 2,
            y: 8,
            style: BarcodeElementStyle(height: 10),
          ),
          BarcodeElement(
            id: 'price',
            type: BarcodeElementType.price,
            x: 28,
            y: 20,
            style: BarcodeElementStyle(fontSize: 11),
          ),
        ],
        isDefault: false,
        isEnabled: true,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
    ];
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
