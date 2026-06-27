import 'dart:typed_data';
import 'dart:convert';
import '../utils/printer_commands.dart';

/// 打印机指令服务 - 支持 TSPL/ESC 指令生成
class PrinterCommandService {
  
  // ========== ESC/POS 指令集 (通用热敏打印机) ==========
  
  /// ESC 初始化打印机
  static List<int> escInit() {
    return [0x1B, 0x40]; // ESC @
  }
  
  /// ESC 切纸
  static List<int> escCut() {
    return [0x1D, 0x56, 0x01]; // GS V 1
  }
  
  /// ESC 走纸
  static List<int> escFeed(int lines) {
    return [0x1B, 0x64, lines]; // ESC d n
  }
  
  /// ESC 设置对齐方式
  static List<int> escAlign(int align) {
    // 0=左对齐, 1=居中, 2=右对齐
    return [0x1B, 0x61, align]; // ESC a n
  }
  
  /// ESC 设置字体大小
  static List<int> escFontSize(int width, int height) {
    // width, height: 1-8
    int size = ((width - 1) << 4) | (height - 1);
    return [0x1D, 0x21, size]; // GS ! n
  }
  
  /// ESC 加粗
  static List<int> escBold(bool on) {
    return [0x1B, 0x45, on ? 1 : 0]; // ESC E n
  }
  
  /// ESC 打印文本
  static List<int> escText(String text, {String encoding = 'GBK'}) {
    List<int> bytes;
    try {
      bytes = Encoding.getByName(encoding)!.encode(text);
    } catch (e) {
      bytes = utf8.encode(text);
    }
    return [...bytes, 0x0A]; // 加换行
  }
  
  /// ESC 打印一维条码 (CODE128)
  static List<int> escBarcode(String content, {int width = 2, int height = 100}) {
    List<int> commands = [];
    // 设置条码宽度
    commands.addAll([0x1D, 0x77, width]); // GS w n
    // 设置条码高度
    commands.addAll([0x1D, 0x68, height]); // GS h n
    // 设置条码位置 (下方打印文字)
    commands.addAll([0x1D, 0x48, 2]); // GS H 2
    // 设置条码类型为 CODE128
    commands.addAll([0x1D, 0x6B, 73]); // GS k 73
    // 条码内容长度 + 内容
    List<int> contentBytes = content.codeUnits;
    commands.add(contentBytes.length);
    commands.addAll(contentBytes);
    commands.add(0x00); // 结束符
    return commands;
  }
  
  /// ESC 打印 QR 码
  static List<int> escQRCode(String content, {int size = 6}) {
    List<int> commands = [];
    List<int> contentBytes = utf8.encode(content);
    int length = contentBytes.length + 3;
    
    // 设置 QR 码大小
    commands.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, size]);
    // 设置纠错级别
    commands.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x31]);
    // 存储数据
    commands.addAll([0x1D, 0x28, 0x6B, length & 0xFF, (length >> 8) & 0xFF, 0x31, 0x50, 0x30]);
    commands.addAll(contentBytes);
    // 打印 QR 码
    commands.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
    
    return commands;
  }
  
  // ========== TSPL 指令集 (TSC 标签打印机) ==========
  
  /// TSPL 初始化
  static String tsplInit() {
    return 'CLS\n'; // 清除图像缓存
  }
  
  /// TSPL 设置标签尺寸
  static String tsplSize(int width, int height, {int gap = 2}) {
    // width/height in mm
    return 'SIZE $width mm,$height mm\nGAP $gap mm\n';
  }
  
  /// TSPL 设置打印方向
  static String tsplDirection(int direction) {
    // 0=正常, 1=旋转180度
    return 'DIRECTION $direction\n';
  }
  
  /// TSPL 打印文本
  static String tsplText(int x, int y, String text, {
    String font = 'TSS24.BF2',
    int rotation = 0,
    int xScale = 1,
    int yScale = 1,
  }) {
    // TEXT x,y,"font",rotation,xScale,yScale,"content"
    return 'TEXT $x,$y,"$font",$rotation,$xScale,$yScale,"$text"\n';
  }
  
  /// TSPL 打印一维条码 (CODE128)
  static String tsplBarcode(int x, int y, String content, {
    String type = '128',
    int height = 50,
    int narrow = 2,
    int wide = 4,
    int rotation = 0,
    bool readable = true,
  }) {
    // BARCODE x,y,"type",height,narrow,wide,rotation,"content"
    String readFlag = readable ? '0' : '1';
    return 'BARCODE $x,$y,"$type",$height,$narrow,$wide,$rotation,"$content"\n';
  }
  
  /// TSPL 打印 QR 码
  static String tsplQRCode(int x, int y, String content, {
    int width = 6,
    int rotation = 0,
    String ecc = 'M',
  }) {
    // QRCODE x,y,ECC,rotation,width,auto,content
    return 'QRCODE $x,$y,$ecc,$rotation,$width,M,"$content"\n';
  }
  
  /// TSPL 打印图片 (简化版 - 使用 BITMAP 指令)
  static String tsplBitmap(int x, int y, int width, int height, Uint8List data) {
    // BITMAP x,y,width,height,mode,bitmap_data
    int byteWidth = (width + 7) ~/ 8;
    return 'BITMAP $x,$y,$byteWidth,$height,1,${base64Encode(data)}\n';
  }
  
  /// TSPL 打印
  static String tsplPrint(int copies) {
    return 'PRINT $copies\n';
  }
  
  /// TSPL 结束
  static String tsplEnd() {
    return 'END\n';
  }
  
  // ========== 实用工具方法 ==========
  
  /// 生成小票 ESC 指令
  static List<int> generateReceiptEsc({
    required String shopName,
    required String shopAddress,
    required String orderNo,
    required String orderTime,
    required String cashier,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerName,
    String? paymentMethod,
  }) {
    List<int> commands = [];
    
    // 初始化
    commands.addAll(escInit());
    
    // 店铺名称 - 居中放大
    commands.addAll(escAlign(1));
    commands.addAll(escFontSize(2, 2));
    commands.addAll(escBold(true));
    commands.addAll(escText(shopName));
    commands.addAll(escBold(false));
    commands.addAll(escFontSize(1, 1));
    commands.addAll(escText(shopAddress));
    commands.addAll(escFeed(1));
    
    // 分隔线
    commands.addAll(escAlign(0));
    commands.addAll(escText('=' * 32));
    
    // 订单信息
    commands.addAll(escText('单号: $orderNo'));
    commands.addAll(escText('时间: $orderTime'));
    commands.addAll(escText('收银: $cashier'));
    if (customerName != null) {
      commands.addAll(escText('会员: $customerName'));
    }
    commands.addAll(escFeed(1));
    
    // 商品表头
    commands.addAll(escText('商品         数量  单价  小计'));
    commands.addAll(escText('-' * 32));
    
    // 商品列表
    for (var item in items) {
      String name = item['name'].toString().padRight(12).substring(0, 12);
      String qty = item['quantity'].toString().padLeft(4);
      String price = item['price'].toStringAsFixed(2).padLeft(6);
      String amount = item['amount'].toStringAsFixed(2).padLeft(6);
      commands.addAll(escText('$name$qty$price$amount'));
    }
    
    commands.addAll(escText('-' * 32));
    
    // 合计
    commands.addAll(escAlign(2));
    commands.addAll(escBold(true));
    commands.addAll(escText('合计: ¥${totalAmount.toStringAsFixed(2)}'));
    commands.addAll(escBold(false));
    if (paymentMethod != null) {
      commands.addAll(escText('支付: $paymentMethod'));
    }
    commands.addAll(escFeed(1));
    
    // 条码
    commands.addAll(escAlign(1));
    commands.addAll(escBarcode(orderNo));
    commands.addAll(escFeed(2));
    
    // 底部文字
    commands.addAll(escText('感谢惠顾'));
    commands.addAll(escText('欢迎下次光临'));
    commands.addAll(escFeed(3));
    
    // 切纸
    commands.addAll(escCut());
    
    return commands;
  }
  
  /// 生成条码标签 TSPL 指令
  static String generateBarcodeTspl({
    required String barcode,
    required String productName,
    String? spec,
    double? price,
    int labelWidth = 40,
    int labelHeight = 30,
  }) {
    StringBuffer sb = StringBuffer();
    
    // 初始化
    sb.write(tsplInit());
    sb.write(tsplSize(labelWidth, labelHeight));
    sb.write(tsplDirection(0));
    
    // 商品名称 (顶部)
    sb.write(tsplText(10, 10, productName.length > 10 
        ? '${productName.substring(0, 10)}...' 
        : productName));
    
    // 规格
    if (spec != null) {
      sb.write(tsplText(10, 40, spec, font: 'TSS16.BF2'));
    }
    
    // 条码 (中间)
    int barcodeY = spec != null ? 65 : 50;
    sb.write(tsplBarcode(10, barcodeY, barcode, height: 40));
    
    // 价格 (右下角)
    if (price != null) {
      sb.write(tsplText(200, 100, '¥${price.toStringAsFixed(2)}', 
          font: 'TSS24.BF2', xScale: 2, yScale: 2));
    }
    
    // 打印
    sb.write(tsplPrint(1));
    sb.write(tsplEnd());
    
    return sb.toString();
  }
  
  /// 生成多排条码标签 TSPL (用于打印 SKU 条码页)
  static String generateBarcodeSheetTspl({
    required List<Map<String, dynamic>> products,
    int labelWidth = 40,
    int labelHeight = 30,
    int columns = 2,
    int rows = 5,
  }) {
    StringBuffer sb = StringBuffer();
    
    int sheetWidth = labelWidth * columns;
    int sheetHeight = labelHeight * rows;
    
    sb.write(tsplInit());
    sb.write(tsplSize(sheetWidth, sheetHeight));
    sb.write(tsplDirection(0));
    
    for (int i = 0; i < products.length && i < columns * rows; i++) {
      var product = products[i];
      int col = i % columns;
      int row = i ~/ columns;
      int offsetX = col * labelWidth * 8; // 转换为点 (1mm = 8 dots @ 203dpi)
      int offsetY = row * labelHeight * 8;
      
      // 商品名称
      String name = product['name'].toString();
      sb.write(tsplText(offsetX + 10, offsetY + 10, 
          name.length > 8 ? '${name.substring(0, 8)}..' : name,
          font: 'TSS16.BF2'));
      
      // 条码
      sb.write(tsplBarcode(offsetX + 10, offsetY + 35, 
          product['barcode'], height: 35, narrow: 2, wide: 4));
      
      // 价格
      if (product['price'] != null) {
        sb.write(tsplText(offsetX + 160, offsetY + 90, 
            '¥${product['price'].toStringAsFixed(0)}',
            font: 'TSS20.BF2'));
      }
    }
    
    sb.write(tsplPrint(1));
    sb.write(tsplEnd());
    
    return sb.toString();
  }
}

/// ASCII 编码帮助
class AsciiEncoder extends Converter<String, List<int>> {
  @override
  List<int> convert(String input) {
    return input.codeUnits;
  }
}

List<int> get ascii => AsciiEncoder().convert("");
