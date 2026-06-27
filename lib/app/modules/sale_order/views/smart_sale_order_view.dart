import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/sale_order_controller.dart';
import '../../../services/voice_service.dart';
import '../../../services/image_recognition_service.dart';
import '../../../services/voice_service.dart' show SmartOrderItem;
import '../../../services/image_recognition_service.dart' show RecognizedItem;
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../product/controllers/product_controller.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';

/// 智能开单页面 - 支持语音和图片识别
class SmartSaleOrderView extends StatefulWidget {
  const SmartSaleOrderView({Key? key}) : super(key: key);

  @override
  State<SmartSaleOrderView> createState() => _SmartSaleOrderViewState();
}

class _SmartSaleOrderViewState extends State<SmartSaleOrderView> {
  late final SaleOrderController saleController;
  final voiceService = Get.put(VoiceService());
  final imageService = Get.put(ImageRecognitionService());
  late final ProductController productController;
  late final CustomerController customerController;
  late final WarehouseController warehouseController;

  final _textController = TextEditingController();
  
  // 识别结果
  SmartOrderParseResult? _voiceResult;
  ImageRecognitionResult? _imageResult;

  @override
  void initState() {
    super.initState();
    // 安全初始化控制器
    saleController = Get.isRegistered<SaleOrderController>()
        ? Get.find<SaleOrderController>()
        : Get.put(SaleOrderController());
    productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
    customerController = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());
    warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    
    // 监听语音识别结果
    voiceService.recognitionStream.listen((text) {
      setState(() {
        _textController.text = text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '智能开单',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(icon: TDIcons.chevron_left, iconColor: Colors.white, action: () => Get.back()),
        ],
      ),
      body: Column(
        children: [
          // 输入区域
          _buildInputArea(),
          
          // 识别结果预览
          if (_voiceResult != null || _imageResult != null)
            Expanded(child: _buildResultPreview()),
        ],
      ),
    );
  }

  /// 输入区域
  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 语音按钮
          _buildVoiceButton(),
          
          const SizedBox(height: 16),
          
          // 或者文字输入
          TDInput(
            controller: _textController,
            hintText: '说话或输入订单内容，例如："给张三发5箱可乐，3箱雪碧"',
            maxLines: 3,
            onChanged: (v) {},
          ),
          
          const SizedBox(height: 16),
          
          // 图片识别按钮
          _buildImageButtons(),
          
          const SizedBox(height: 16),
          
          // 解析按钮
          Obx(() => TDButton(
            text: voiceService.isProcessing.value ? '解析中...' : '智能解析',
            theme: TDButtonTheme.primary,
            size: TDButtonSize.large,
            isBlock: true,
            icon: Icons.auto_fix_high,
            disabled: voiceService.isProcessing.value || _textController.text.isEmpty,
            onTap: _parseText,
          )),
        ],
      ),
    );
  }

  /// 语音按钮
  Widget _buildVoiceButton() {
    return Obx(() {
      final isListening = voiceService.isListening.value;
      
      return GestureDetector(
        onTap: isListening ? _stopListening : _startListening,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: isListening ? Colors.red.withOpacity(0.1) : const Color(0xFF2FC27D).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isListening ? Colors.red : const Color(0xFF2FC27D),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isListening ? Icons.mic : Icons.mic_none,
                size: 48,
                color: isListening ? Colors.red : const Color(0xFF2FC27D),
              ),
              const SizedBox(height: 8),
              TDText(
                isListening ? '点击结束' : '点击说话',
                textColor: isListening ? Colors.red : const Color(0xFF2FC27D),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 图片按钮
  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: TDButton(
            text: '拍照识别',
            theme: TDButtonTheme.light,
            size: TDButtonSize.medium,
            icon: TDIcons.camera,
            isBlock: true,
            onTap: _captureAndRecognize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TDButton(
            text: '相册选择',
            theme: TDButtonTheme.light,
            size: TDButtonSize.medium,
            icon: TDIcons.image,
            isBlock: true,
            onTap: _pickAndRecognize,
          ),
        ),
      ],
    );
  }

  /// 识别结果预览
  Widget _buildResultPreview() {
    final result = _voiceResult ?? _imageResult;
    if (result == null) return const SizedBox.shrink();

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
          // 标题
          Row(
            children: [
              Icon(TDIcons.check_circle, color: const Color(0xFF2FC27D)),
              const SizedBox(width: 8),
              const TDText('识别结果', fontWeight: FontWeight.bold),
              const Spacer(),
              TDButton(
                text: '重新识别',
                theme: TDButtonTheme.light,
                size: TDButtonSize.small,
                onTap: () {
                  setState(() {
                    _voiceResult = null;
                    _imageResult = null;
                  });
                },
              ),
            ],
          ),
          
          const Divider(),
          
          // 客户信息
          if (result is SmartOrderParseResult && result.customerName != null)
            _buildInfoRow('客户', result.customerName!),
          if (result is ImageRecognitionResult && result.customerName != null)
            _buildInfoRow('客户', '${result.customerName}${result.customerPhone != null ? ' (${result.customerPhone})' : ''}'),
          
          // 商品列表
          const SizedBox(height: 12),
          const TDText('商品明细', fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          
          Expanded(
            child: ListView.builder(
              itemCount: result is SmartOrderParseResult 
                  ? result.items.length 
                  : (result as ImageRecognitionResult).items.length,
              itemBuilder: (context, index) {
                final item = result is SmartOrderParseResult 
                    ? result.items[index] 
                    : (result as ImageRecognitionResult).items[index];
                
                return _buildItemCard(item, index);
              },
            ),
          ),
          
          // 总金额
          if (result is ImageRecognitionResult && result.totalAmount != null)
            _buildInfoRow('识别金额', '¥${result.totalAmount!.toStringAsFixed(2)}'),
          
          // 备注
          if (result is SmartOrderParseResult && result.remark != null)
            _buildInfoRow('备注', result.remark!),
          if (result is ImageRecognitionResult && result.remark != null)
            _buildInfoRow('备注', result.remark!),
          
          const SizedBox(height: 16),
          
          // 确认按钮
          TDButton(
            text: '创建订单',
            theme: TDButtonTheme.primary,
            size: TDButtonSize.large,
            isBlock: true,
            onTap: () => _createOrderFromResult(result),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          TDText('$label：', textColor: Colors.grey),
          Expanded(child: TDText(value)),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(
                  (item as dynamic).productName,
                  fontWeight: FontWeight.bold,
                ),
                if (item is SmartOrderItem && item.confidence != null)
                  TDText(
                    '匹配置信度: ${(item.confidence! * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          TDText('${(item as dynamic).quantity}${(item as dynamic).unit ?? '件'}'),
          if ((item as dynamic).price != null)
            TDText(' ¥${(item as dynamic).price!.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  // ==================== 事件处理 ====================

  /// 开始语音识别
  Future<void> _startListening() async {
    await voiceService.startListening(language: 'zh-CN');
  }

  /// 停止语音识别
  Future<void> _stopListening() async {
    await voiceService.stopListening();
    
    // 如果有识别结果，自动解析
    if (voiceService.recognizedText.value.isNotEmpty) {
      _textController.text = voiceService.recognizedText.value;
      _parseText();
    }
  }

  /// 解析文本
  Future<void> _parseText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final result = await voiceService.parseOrderFromText(text);
    
    setState(() {
      _voiceResult = result;
      _imageResult = null;
    });

    if (!result.success) {
      Get.snackbar('提示', result.message);
    }
  }

  /// 拍照识别
  Future<void> _captureAndRecognize() async {
    final result = await imageService.captureAndRecognize();
    if (result != null && result.success) {
      setState(() {
        _imageResult = result;
        _voiceResult = null;
      });
    } else if (result != null) {
      Get.snackbar('提示', result.message);
    }
  }

  /// 相册选择识别
  Future<void> _pickAndRecognize() async {
    final result = await imageService.pickAndRecognize();
    if (result != null && result.success) {
      setState(() {
        _imageResult = result;
        _voiceResult = null;
      });
    } else if (result != null) {
      Get.snackbar('提示', result.message);
    }
  }

  /// 根据识别结果创建订单
  Future<void> _createOrderFromResult(dynamic result) async {
    // 清空当前订单项
    saleController.clearItems();

    // 匹配客户
    if (result is SmartOrderParseResult && result.customerName != null) {
      final customer = customerController.customers.firstWhereOrNull(
        (c) => c.name.contains(result.customerName!) || result.customerName!.contains(c.name),
      );
      if (customer != null) {
        saleController.selectCustomer(customer);
      }
    }
    if (result is ImageRecognitionResult && result.customerName != null) {
      final customer = customerController.customers.firstWhereOrNull(
        (c) => c.name.contains(result.customerName!) || result.customerName!.contains(c.name),
      );
      if (customer != null) {
        saleController.selectCustomer(customer);
      }
    }

    // 默认第一个仓库
    if (warehouseController.warehouses.isNotEmpty) {
      saleController.selectWarehouse(warehouseController.warehouses.first);
    }

    // 添加商品项
    final items = result is SmartOrderParseResult 
        ? result.items 
        : (result as ImageRecognitionResult).items;

    for (final rawItem in items) {
      // 根据类型转换
      final item = rawItem is SmartOrderItem 
          ? rawItem 
          : (rawItem as RecognizedItem);
      
      // 尝试匹配商品
      Product? matchedProduct;
      
      if (item is SmartOrderItem && (item as dynamic).matchedProductId != null) {
        matchedProduct = productController.products.firstWhereOrNull(
          (p) => p.id == (item as dynamic).matchedProductId,
        );
      }
      
      // 按名称模糊匹配
      if (matchedProduct == null) {
        matchedProduct = productController.products.firstWhereOrNull(
          (p) => p.name.contains((item as dynamic).productName) || (item as dynamic).productName.contains(p.name),
        );
      }

      if (matchedProduct != null) {
        saleController.addOrderItem(
          matchedProduct,
          (item as dynamic).quantity,
          (item as dynamic).price ?? matchedProduct.salePrice ?? 0,
        );
      } else {
        // 未匹配到商品，创建临时商品
        final tempProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch + items.indexOf(rawItem),
          name: (item as dynamic).productName,
          code: 'TEMP${DateTime.now().millisecondsSinceEpoch}',
          unit: (item as dynamic).unit ?? '件',
          purchasePrice: 0,
          salePrice: (item as dynamic).price ?? 0,
          stock: 0,
          minStock: 0,
        );
        saleController.addOrderItem(tempProduct, (item as dynamic).quantity, (item as dynamic).price ?? 0);
      }
    }

    // 设置备注
    if (result is SmartOrderParseResult && result.remark != null) {
      saleController.remark.value = result.remark!;
    }
    if (result is ImageRecognitionResult && result.remark != null) {
      saleController.remark.value = result.remark!;
    }

    // 跳转到订单创建页面进行确认
    Get.toNamed('/sale-order/create');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
