import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/models/print_template_model.dart';
import 'printer_command_service.dart';
import '../core/utils/logger.dart';

/// 打印服务 - 支持后端PDF生成和蓝牙打印
/// 注意：蓝牙功能暂时注释，如需启用请取消 pubspec.yaml 中的 flutter_bluetooth_serial 依赖
class PrintService extends GetxService {
  late final Dio _dio;
  // final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  @override
  void onInit() {
    super.onInit();
    _dio = Get.isRegistered<Dio>() ? Get.find<Dio>() : Dio();
  }

  // 蓝牙打印机状态
  final isScanning = false.obs;
  final isPrinterConnected = false.obs;
  // final connectedPrinter = Rx<BluetoothDevice?>(null);
  // final discoveredPrinters = <BluetoothDevice>[].obs;
  final connectedPrinter = Rx<dynamic>(null);
  final discoveredPrinters = <dynamic>[].obs;

  // BluetoothConnection? _printerConnection;
  StreamSubscription<Uint8List>? _printerDataSubscription;

  // 默认打印模版
  final _defaultReceiptTemplate = PrintTemplate(
    id: 'default_receipt',
    name: '默认小票',
    type: 'receipt',
    description: '80mm热敏打印机小票模版',
    paperSize: PaperSize.mm80,
    isDefault: true,
    isEnabled: true,
    globalStyle: PrintStyle(fontSize: 12, align: 'left'),
    elements: [
      // 店铺标题
      PrintElement(
        id: 'shop_name',
        type: 'text',
        field: PrintFields.shopName,
        style: PrintStyle(fontSize: 16, isBold: true, align: 'center'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 分隔线
      PrintElement(
        id: 'line1',
        type: 'line',
        style: PrintStyle(),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 订单号
      PrintElement(
        id: 'order_no',
        type: 'text',
        field: PrintFields.orderNo,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 时间
      PrintElement(
        id: 'order_time',
        type: 'text',
        field: PrintFields.orderTime,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 分隔线
      PrintElement(
        id: 'line2',
        type: 'line',
        style: PrintStyle(),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 商品表头
      PrintElement(
        id: 'table_header',
        type: 'text',
        customText: '商品名称          数量    单价    小计',
        style: PrintStyle(fontSize: 10, isBold: true),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 商品列表
      PrintElement(
        id: 'items_table',
        type: 'table',
        field: PrintFields.itemsTable,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 分隔线
      PrintElement(
        id: 'line3',
        type: 'line',
        style: PrintStyle(),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 合计
      PrintElement(
        id: 'total_amount',
        type: 'text',
        field: PrintFields.totalAmount,
        style: PrintStyle(fontSize: 12, isBold: true, align: 'right'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 付款方式
      PrintElement(
        id: 'payment_method',
        type: 'text',
        field: PrintFields.paymentMethod,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 分隔线
      PrintElement(
        id: 'line4',
        type: 'line',
        style: PrintStyle(),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 收银员
      PrintElement(
        id: 'cashier',
        type: 'text',
        field: PrintFields.cashierName,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 打印时间
      PrintElement(
        id: 'print_time',
        type: 'text',
        field: PrintFields.printTime,
        style: PrintStyle(fontSize: 9, align: 'center'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 欢迎语
      PrintElement(
        id: 'welcome',
        type: 'text',
        customText: '感谢惠顾，欢迎下次光临！',
        style: PrintStyle(fontSize: 10, align: 'center'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
    ],
    createTime: DateTime.now(),
    updateTime: DateTime.now(),
  );

  // 默认发货单模版
  final _defaultDeliveryTemplate = PrintTemplate(
    id: 'default_delivery',
    name: '默认发货单',
    type: 'delivery',
    description: 'A5发货单模版',
    paperSize: PaperSize.a5,
    isDefault: true,
    isEnabled: true,
    globalStyle: PrintStyle(fontSize: 12, align: 'left'),
    elements: [
      // 标题
      PrintElement(
        id: 'title',
        type: 'text',
        customText: '发 货 单',
        style: PrintStyle(fontSize: 20, isBold: true, align: 'center'),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 订单信息
      PrintElement(
        id: 'order_no',
        type: 'text',
        field: PrintFields.orderNo,
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'order_time',
        type: 'text',
        field: PrintFields.orderTime,
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 客户信息
      PrintElement(
        id: 'customer_info',
        type: 'text',
        customText: '收货人信息：',
        style: PrintStyle(fontSize: 11, isBold: true),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'customer_name',
        type: 'text',
        field: PrintFields.customerName,
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'customer_phone',
        type: 'text',
        field: PrintFields.customerPhone,
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'customer_address',
        type: 'text',
        field: PrintFields.customerAddress,
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 发货商品列表
      PrintElement(
        id: 'items_header',
        type: 'text',
        customText: '发货明细：',
        style: PrintStyle(fontSize: 11, isBold: true),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'items_table',
        type: 'table',
        field: PrintFields.itemsTable,
        style: PrintStyle(fontSize: 10),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      // 签名区
      PrintElement(
        id: 'sign_area',
        type: 'text',
        customText: '收货人签字：_______________',
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
      PrintElement(
        id: 'sign_date',
        type: 'text',
        customText: '签收日期：_______________',
        style: PrintStyle(fontSize: 11),
        position: PrintPosition(),
        size: PrintSize(),
      ),
    ],
    createTime: DateTime.now(),
    updateTime: DateTime.now(),
  );

  /// 获取默认模版列表
  List<PrintTemplate> getDefaultTemplates() {
    return [_defaultReceiptTemplate, _defaultDeliveryTemplate];
  }

  /// 获取模版列表
  Future<List<PrintTemplate>> getTemplates({String? type}) async {
    try {
      // 从后端API获取模版列表
      final response = await _dio.get(
        '/api/print/templates',
        queryParameters: type != null ? {'type': type} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => PrintTemplate.fromJson(e)).toList();
      }
    } catch (e) {
      Logger.e('获取模版列表失败', error: e);
    }

    // 返回默认模版
    return getDefaultTemplates();
  }

  /// 获取单个模版
  Future<PrintTemplate?> getTemplate(String id) async {
    try {
      // 从后端API获取模版
      final response = await _dio.get('/api/print/templates/$id');

      if (response.statusCode == 200) {
        return PrintTemplate.fromJson(response.data['data']);
      }
    } catch (e) {
      Logger.e('获取模版失败', error: e);
    }

    // 如果是默认模版ID，返回默认模版
    if (id == 'default_receipt') return _defaultReceiptTemplate;
    if (id == 'default_delivery') return _defaultDeliveryTemplate;

    return null;
  }

  /// 获取默认模版
  Future<PrintTemplate?> getDefaultTemplate(String type) async {
    final templates = await getTemplates(type: type);
    return templates.firstWhereOrNull((t) => t.isDefault && t.isEnabled)
        ?? templates.firstWhereOrNull((t) => t.isEnabled);
  }

  /// 保存模版
  Future<bool> saveTemplate(PrintTemplate template) async {
    try {
      final response = await _dio.post(
        '/api/print/templates',
        data: template.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      Logger.e('保存模版失败', error: e);
      return false;
    }
  }

  /// 更新模版
  Future<bool> updateTemplate(String id, PrintTemplate template) async {
    try {
      final response = await _dio.put(
        '/api/print/templates/$id',
        data: template.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      Logger.e('更新模版失败', error: e);
      return false;
    }
  }

  /// 删除模版
  Future<bool> deleteTemplate(String id) async {
    try {
      final response = await _dio.delete('/api/print/templates/$id');
      return response.statusCode == 200;
    } catch (e) {
      Logger.e('删除模版失败', error: e);
      return false;
    }
  }

  /// 生成PDF打印任务
  /// 返回任务ID，后续轮询查询PDF生成状态
  Future<String?> createPrintJob({
    required String templateId,
    required String documentType,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/api/print/jobs',
        data: {
          'templateId': templateId,
          'documentType': documentType,
          'documentId': documentId,
          'data': data,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data']['jobId'];
      }
    } catch (e) {
      Logger.e('创建打印任务失败', error: e);
    }
    return null;
  }

  /// 查询打印任务状态
  Future<PrintJob?> getPrintJobStatus(String jobId) async {
    try {
      final response = await _dio.get('/api/print/jobs/$jobId');

      if (response.statusCode == 200) {
        return PrintJob.fromJson(response.data['data']);
      }
    } catch (e) {
      Logger.e('查询打印任务失败', error: e);
    }
    return null;
  }

  /// 下载PDF文件
  Future<File?> downloadPdf(String url, String savePath) async {
    try {
      final response = await _dio.download(url, savePath);
      if (response.statusCode == 200) {
        return File(savePath);
      }
    } catch (e) {
      Logger.e('下载PDF失败', error: e);
    }
    return null;
  }

  /// 快速打印订单
  /// 封装完整的打印流程：创建任务 -> 等待PDF生成 -> 打印
  Future<bool> printOrder({
    required String orderId,
    required Map<String, dynamic> orderData,
    String? templateId,
  }) async {
    try {
      // 1. 获取模版
      PrintTemplate? template;
      if (templateId != null) {
        final templates = await getTemplates();
        template = templates.firstWhereOrNull((t) => t.id == templateId);
      }
      template ??= await getDefaultTemplate('receipt');

      if (template == null) {
        throw Exception('没有可用的打印模版');
      }

      // 2. 创建打印任务
      final jobId = await createPrintJob(
        templateId: template.id,
        documentType: 'order',
        documentId: orderId,
        data: orderData,
      );

      if (jobId == null) {
        throw Exception('创建打印任务失败');
      }

      // 3. 轮询等待PDF生成
      PrintJob? job;
      for (var i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 1));
        job = await getPrintJobStatus(jobId);

        if (job == null) continue;

        if (job.status == 'completed' && job.pdfUrl != null) {
          // PDF生成成功，返回成功
          return true;
        } else if (job.status == 'failed') {
          throw Exception(job.errorMessage ?? 'PDF生成失败');
        }
      }

      throw Exception('等待PDF生成超时');
    } catch (e) {
      Logger.e('打印订单失败', error: e);
      return false;
    }
  }

  /// 预览PDF（获取PDF URL）
  Future<String?> previewPdf({
    required String templateId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/api/print/preview',
        data: {
          'templateId': templateId,
          'data': data,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data']['pdfUrl'];
      }
    } catch (e) {
      Logger.e('预览PDF失败', error: e);
    }
    return null;
  }

  // ========== 蓝牙热敏打印机功能 (ESC/TSPL 指令) ==========

  /// 开始扫描蓝牙打印机
  Future<void> scanPrinters() async {
    Get.snackbar('提示', '蓝牙打印功能暂未启用，请在 pubspec.yaml 中启用 flutter_bluetooth_serial');
    return;
  }

  /// 停止扫描
  Future<void> stopScanPrinters() async {
    isScanning.value = false;
    // await _bluetooth.cancelDiscovery();
  }

  /// 连接打印机
  Future<bool> connectPrinter(dynamic device) async {
    Get.snackbar('提示', '蓝牙打印功能暂未启用');
    return false;
  }

  /// 断开打印机连接
  Future<void> disconnectPrinter() async {
    await _printerDataSubscription?.cancel();
    _printerDataSubscription = null;
    // await _printerConnection?.close();
    // _printerConnection = null;
    connectedPrinter.value = null;
    isPrinterConnected.value = false;
  }

  /// 通过 ESC 指令打印小票
  Future<bool> printReceiptEsc({
    required String shopName,
    required String orderNo,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? shopAddress,
    String? orderTime,
    String? cashier,
    String? customerName,
    String? paymentMethod,
  }) async {
    Get.snackbar('提示', '蓝牙打印功能暂未启用');
    return false;
  }

  /// 打印测试页
  Future<bool> printTestPage() async {
    Get.snackbar('提示', '蓝牙打印功能暂未启用');
    return false;
  }

  @override
  void onClose() {
    disconnectPrinter();
    super.onClose();
  }
}
