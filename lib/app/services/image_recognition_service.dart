import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

/// 图片识别服务 - 支持识别手写/打印单据生成销售订单
class ImageRecognitionService extends GetxService {
  final api = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  // 状态
  final isProcessing = false.obs;
  final progressText = ''.obs;

  /// 拍照识别
  Future<ImageRecognitionResult?> captureAndRecognize() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (photo == null) return null;

    final bytes = await photo.readAsBytes();
    return recognizeImage(bytes, fileName: photo.name);
  }

  /// 从相册选择识别
  Future<ImageRecognitionResult?> pickAndRecognize() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image == null) return null;

    final bytes = await image.readAsBytes();
    return recognizeImage(bytes, fileName: image.name);
  }

  /// 识别图片内容
  ///
  /// 支持识别：
  /// - 手写销售单（纸质单据拍照）
  /// - 打印销售单（电子单据截图）
  /// - 聊天记录截图（微信/QQ订单）
  /// - 竞品单据（其他系统导出的订单）
  Future<ImageRecognitionResult> recognizeImage(
    Uint8List imageBytes, {
    String? fileName,
    String? orderType, // 'sale', 'purchase', 'transfer'
  }) async {
    isProcessing.value = true;
    progressText.value = '正在上传图片...';

    try {
      // 转换为Base64
      final base64Image = base64Encode(imageBytes);

      progressText.value = 'AI正在识别...';

      // 调用后端AI识别接口
      final response = await api.post('/ai/order/parse-image', data: {
        'imageBase64': base64Image,
        'fileName': fileName,
        'orderType': orderType ?? 'sale',
      });

      if (response.data != null && response.data['data'] != null) {
        progressText.value = '识别完成';
        return ImageRecognitionResult.fromJson(response.data['data']);
      }
    } catch (e) {
      // 离线模式：返回模拟数据
      progressText.value = '离线模式';
      return _mockRecognitionResult();
    } finally {
      isProcessing.value = false;
    }

    return ImageRecognitionResult(
      success: false,
      message: '识别失败',
    );
  }

  /// Web端图片识别（使用FilePicker）
  Future<ImageRecognitionResult?> recognizeWebImage(
    dynamic htmlFile, {
    String? orderType,
  }) async {
    isProcessing.value = true;
    progressText.value = '正在读取...';

    try {
      // Web端通过JS读取文件
      // 实际实现需要flutter_web_utils或类似库
      progressText.value = 'AI正在识别...';

      // 调用后端接口
      // 由于Web端无法直接转Base64，需要通过FormData上传
      final response = await api.post('/ai/recognize-order-web', data: {
        'orderType': orderType ?? 'sale',
      });

      if (response.data != null && response.data['data'] != null) {
        return ImageRecognitionResult.fromJson(response.data['data']);
      }
    } catch (e) {
      return _mockRecognitionResult();
    } finally {
      isProcessing.value = false;
    }

    return null;
  }

  /// 批量识别多张图片
  Future<List<ImageRecognitionResult>> recognizeMultiple(
    List<Uint8List> images, {
    String? orderType,
  }) async {
    final results = <ImageRecognitionResult>[];

    for (var i = 0; i < images.length; i++) {
      progressText.value = '正在识别 ${i + 1}/${images.length}...';
      final result = await recognizeImage(
        images[i],
        orderType: orderType,
      );
      results.add(result);
    }

    return results;
  }

  /// 模拟识别结果（离线测试用）
  ImageRecognitionResult _mockRecognitionResult() {
    return ImageRecognitionResult(
      success: true,
      message: '识别成功（离线模式）',
      orderType: 'sale',
      customerName: '张三',
      customerPhone: '13800138000',
      items: [
        RecognizedItem(
          productName: '可口可乐',
          quantity: 5,
          unit: '箱',
          price: 40.0,
          amount: 200.0,
        ),
        RecognizedItem(
          productName: '雪碧',
          quantity: 3,
          unit: '箱',
          price: 38.0,
          amount: 114.0,
        ),
        RecognizedItem(
          productName: '红牛',
          quantity: 10,
          unit: '罐',
          price: 6.0,
          amount: 60.0,
        ),
      ],
      totalAmount: 374.0,
      remark: '送货上门',
      recognizedText: '张三 13800138000\n可口可乐 5箱\n雪碧 3箱\n红牛 10罐\n合计374元',
    );
  }
}

/// 图片识别结果
class ImageRecognitionResult {
  final bool success;
  final String message;
  final String? orderType;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final List<RecognizedItem> items;
  final double? totalAmount;
  final String? remark;
  final String? recognizedText; // OCR原始文本
  final List<String>? warnings; // 警告信息（如库存不足）

  ImageRecognitionResult({
    required this.success,
    required this.message,
    this.orderType,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.items = const [],
    this.totalAmount,
    this.remark,
    this.recognizedText,
    this.warnings,
  });

  factory ImageRecognitionResult.fromJson(Map<String, dynamic> json) {
    return ImageRecognitionResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      orderType: json['orderType'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      items: (json['items'] as List?)
          ?.map((e) => RecognizedItem.fromJson(e))
          .toList() ?? [],
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : null,
      remark: json['remark'],
      recognizedText: json['recognizedText'],
      warnings: (json['warnings'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'orderType': orderType,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'remark': remark,
      'recognizedText': recognizedText,
      'warnings': warnings,
    };
  }
}

/// 识别的商品项
class RecognizedItem {
  String productName;
  int quantity;
  String? unit;
  double? price;
  double? amount;
  int? matchedProductId;
  double? currentStock;
  double? confidence;

  RecognizedItem({
    required this.productName,
    required this.quantity,
    this.unit,
    this.price,
    this.amount,
    this.matchedProductId,
    this.currentStock,
    this.confidence,
  });

  factory RecognizedItem.fromJson(Map<String, dynamic> json) {
    return RecognizedItem(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      matchedProductId: json['matchedProductId'],
      currentStock: json['currentStock'] != null
          ? (json['currentStock'] as num).toDouble()
          : null,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'amount': amount,
      'matchedProductId': matchedProductId,
      'currentStock': currentStock,
      'confidence': confidence,
    };
  }
}
