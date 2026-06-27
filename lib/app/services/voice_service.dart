import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'api_service.dart';

/// 语音服务 - 支持语音识别和智能开单
class VoiceService extends GetxService {
  final api = Get.find<ApiService>();
  
  // 状态
  final isListening = false.obs;
  final recognizedText = ''.obs;
  final isProcessing = false.obs;
  
  // 识别结果流
  final _recognitionController = StreamController<String>.broadcast();
  Stream<String> get recognitionStream => _recognitionController.stream;
  
  // ==================== 语音识别 ====================
  
  /// 开始语音识别
  /// 
  /// [platform] 平台：'app' 使用本地识别，'web' 使用Web Speech API
  /// [language] 语言：'zh-CN', 'zh-Yue'（粤语）等
  Future<void> startListening({
    String platform = 'app',
    String language = 'zh-CN',
  }) async {
    isListening.value = true;
    recognizedText.value = '';
    
    if (kIsWeb) {
      // Web端调用浏览器Web Speech API
      await _startWebListening(language);
    } else {
      // APP端调用原生插件
      await _startAppListening(language);
    }
  }
  
  /// 停止语音识别
  Future<void> stopListening() async {
    isListening.value = false;
    
    if (kIsWeb) {
      await _stopWebListening();
    } else {
      await _stopAppListening();
    }
  }
  
  /// Web端语音识别（通过JS互操作）
  Future<void> _startWebListening(String language) async {
    // Web Speech API 通过JavaScript通道调用
    // 实际实现需要在index.html中注入JS代码
    recognizedText.value = '正在聆听...（Web）';
  }
  
  Future<void> _stopWebListening() async {
    // 停止Web Speech API
  }
  
  /// APP端语音识别
  Future<void> _startAppListening(String language) async {
    // 使用 speech_to_text 插件
    // 实际项目中添加: speech_to_text: ^6.6.0
    recognizedText.value = '正在聆听...（APP）';
  }
  
  Future<void> _stopAppListening() async {
    // 停止本地语音识别
  }
  
  // ==================== AI智能解析 ====================
  
  /// 智能解析语音/文本为销售订单数据
  /// 
  /// 输入示例：
  /// - "给客户张三发5箱可乐，3箱雪碧，每箱40块"
  /// - "李老板要红牛10箱，脉动5箱，送到他店里"
  Future<SmartOrderParseResult> parseOrderFromText(String text) async {
    isProcessing.value = true;
    
    try {
      // 调用后端AI解析接口
      final response = await api.post('/ai/order/parse-text', data: {
        'text': text,
        'language': 'zh-CN',
      });
      
      if (response.data != null && response.data['data'] != null) {
        return SmartOrderParseResult.fromJson(response.data['data']);
      }
    } catch (e) {
      // 离线模式：本地规则解析
      return _localParseOrder(text);
    } finally {
      isProcessing.value = false;
    }
    
    return SmartOrderParseResult(
      success: false,
      message: '解析失败',
    );
  }
  
  /// 本地规则解析（离线兜底）
  SmartOrderParseResult _localParseOrder(String text) {
    final items = <SmartOrderItem>[];
    String? customerName;
    String? remark;
    
    // 简单规则解析
    // 匹配 "X箱/瓶/个 商品名" 或 "商品名 X箱"
    final quantityPattern = RegExp(r'(\d+)\s*(箱|瓶|罐|包|袋|个|件)\s*([\u4e00-\u9fa5]+)');
    final quantityMatches = quantityPattern.allMatches(text);
    
    for (final match in quantityMatches) {
      final quantity = int.tryParse(match.group(1)!) ?? 1;
      final unit = match.group(2)!;
      final productName = match.group(3)!;
      
      items.add(SmartOrderItem(
        productName: productName,
        quantity: quantity,
        unit: unit,
      ));
    }
    
    // 匹配客户名（"给XX"、"XX要"、"XX客户"）
    final customerPattern = RegExp(r'(?:给|客户|向|卖给)([\u4e00-\u9fa5]{2,4})');
    final customerMatch = customerPattern.firstMatch(text);
    if (customerMatch != null) {
      customerName = customerMatch.group(1);
    }
    
    // 如果没匹配到数量模式，尝试匹配 "商品名 数字"
    if (items.isEmpty) {
      final simplePattern = RegExp(r'([\u4e00-\u9fa5]{2,6})\s*(\d+)\s*(箱|瓶|罐|包)?');
      final simpleMatches = simplePattern.allMatches(text);
      for (final match in simpleMatches) {
        items.add(SmartOrderItem(
          productName: match.group(1)!,
          quantity: int.tryParse(match.group(2)!) ?? 1,
          unit: match.group(3) ?? '件',
        ));
      }
    }
    
    return SmartOrderParseResult(
      success: items.isNotEmpty,
      message: items.isNotEmpty ? '解析成功' : '未能识别商品信息',
      customerName: customerName,
      items: items,
      remark: remark,
      rawText: text,
    );
  }
  
  @override
  void onClose() {
    _recognitionController.close();
    super.onClose();
  }
}

/// 智能解析结果
class SmartOrderParseResult {
  final bool success;
  final String message;
  final String? customerName;
  final String? customerPhone;
  final List<SmartOrderItem> items;
  final String? remark;
  final String? rawText;
  final List<String>? suggestions; // AI建议

  SmartOrderParseResult({
    required this.success,
    required this.message,
    this.customerName,
    this.customerPhone,
    this.items = const [],
    this.remark,
    this.rawText,
    this.suggestions,
  });

  factory SmartOrderParseResult.fromJson(Map<String, dynamic> json) {
    return SmartOrderParseResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List?)
          ?.map((e) => SmartOrderItem.fromJson(e))
          .toList() ?? [],
      remark: json['remark'],
      rawText: json['rawText'],
      suggestions: (json['suggestions'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'remark': remark,
      'rawText': rawText,
      'suggestions': suggestions,
    };
  }
}

/// 智能订单商品项
class SmartOrderItem {
  String productName;
  int quantity;
  String? unit;
  double? price;
  int? matchedProductId; // 匹配到的商品ID
  String? matchedProductCode;
  double? stock; // 当前库存
  double? confidence; // 匹配置信度

  SmartOrderItem({
    required this.productName,
    required this.quantity,
    this.unit,
    this.price,
    this.matchedProductId,
    this.matchedProductCode,
    this.stock,
    this.confidence,
  });

  factory SmartOrderItem.fromJson(Map<String, dynamic> json) {
    return SmartOrderItem(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      matchedProductId: json['matchedProductId'],
      matchedProductCode: json['matchedProductCode'],
      stock: json['stock'] != null ? (json['stock'] as num).toDouble() : null,
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'matchedProductId': matchedProductId,
      'matchedProductCode': matchedProductCode,
      'stock': stock,
      'confidence': confidence,
    };
  }
}
