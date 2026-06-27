import 'dart:typed_data';
import 'dart:convert';
class PrinterCommands {
  
  // ESC/POS 指令
  static const int ESC = 0x1B;
  static const int GS = 0x1D;
  static const int FS = 0x1C;
  static const int DLE = 0x10;
  static const int EOT = 0x04;
  
  /// 初始化打印机
  static List<int> init() {
    return [ESC, 0x40];
  }
  
  /// 换行
  static List<int> newline() {
    return [0x0A, 0x0D];
  }
  
  /// 切纸
  static List<int> cut() {
    return [GS, 0x56, 0x00];
  }
  
  /// 设置对齐方式 (0=左, 1=中, 2=右)
  static List<int> align(int align) {
    return [ESC, 0x61, align];
  }
  
  /// 设置字体大小 (0-7)
  static List<int> setFontSize(int size) {
    return [GS, 0x21, size];
  }
  
  /// 设置粗体
  static List<int> bold(bool on) {
    return [ESC, 0x45, on ? 1 : 0];
  }
  
  /// 打印文本
  static List<int> text(String text) {
    return [...text.codeUnits];
  }
  
  /// 打印条形码 (EAN-13)
  static List<int> barcodeEan13(String data) {
    final cmd = <int>[
      GS, 0x6B, 0x43, // 选择 EAN13
      data.length,    // 数据长度
    ];
    cmd.addAll(data.codeUnits);
    return cmd;
  }
  
  /// 打印条形码 (CODE128)
  static List<int> barcodeCode128(String data, {int width = 2, int height = 100}) {
    final cmd = <int>[
      GS, 0x77, width,      // 宽度
      GS, 0x68, height,     // 高度
      GS, 0x66, 0x00,       // 字体A
      GS, 0x6B, 0x49,       // CODE128
      data.length + 2,      // 数据长度 + {A{BCODE
    ];
    cmd.addAll('{A'.codeUnits); // 开始字符A
    cmd.addAll(data.codeUnits);
    return cmd;
  }
  
  /// 打印二维码
  static List<int> qrCode(String data, {int size = 3}) {
    final cmd = <int>[
      // 设置二维码大小
      GS, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, size,
      // 设置错误纠正级别
      GS, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30,
    ];
    
    // 存储数据
    final dataBytes = data.codeUnits;
    final pL = dataBytes.length + 3;
    final pH = 0;
    
    cmd.addAll([
      GS, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30,
    ]);
    cmd.addAll(dataBytes);
    
    // 打印二维码
    cmd.addAll([GS, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
    
    return cmd;
  }
  
  /// 打开钱箱
  static List<int> openCashDrawer() {
    return [ESC, 0x70, 0x00, 0x19, 0xFA];
  }
}

/// TSPL 指令生成器
class TsplCommands {
  
  /// 设置标签尺寸
  static String setLabelSize(int width, int height) {
    return 'SIZE $width mm,$height mm\r\n';
  }
  
  /// 设置间距
  static String setGap(int gap) {
    return 'GAP $gap mm\r\n';
  }
  
  /// 设置打印方向
  static String setDirection(int direction) {
    return 'DIRECTION $direction\r\n';
  }
  
  /// 清除缓冲区
  static String clearBuffer() {
    return 'CLS\r\n';
  }
  
  /// 文本
  static String text(int x, int y, String font, int rotation, int xScale, int yScale, String text) {
    return 'TEXT $x,$y,"$font",$rotation,$xScale,$yScale,"$text"\r\n';
  }
  
  /// 一维条形码 (128B)
  static String barcode(int x, int y, String type, int height, int human, int rotation, int narrow, int wide, String data) {
    return 'BARCODE $x,$y,"$type",$height,$human,$rotation,$narrow,$wide,"$data"\r\n';
  }
  
  /// 二维码
  static String qrCode(int x, int y, String ecc, int width, int rotation, String data) {
    return 'QRCODE $x,$y,$ecc,$width,A,$rotation,M1,S7,"$data"\r\n';
  }
  
  /// 打印
  static String print(int quantity) {
    return 'PRINT $quantity\r\n';
  }
  
  /// 图片
  static String bitmap(int x, int y, int width, int height, String data) {
    return 'BITMAP $x,$y,$width,$height,1,$data\r\n';
  }
  
  /// 矩形
  static String box(int x, int y, int xEnd, int yEnd, int lineWidth) {
    return 'BOX $x,$y,$xEnd,$yEnd,$lineWidth\r\n';
  }
  
  /// 直线
  static String line(int x, int y, int xEnd, int yEnd, int lineWidth) {
    return 'BAR $x,$y,$xEnd,$yEnd,$lineWidth\r\n';
  }
  
  /// 打印密度设置
  static String density(int density) {
    return 'DENSITY $density\r\n';
  }
  
  /// 打印速度
  static String speed(int speed) {
    return 'SPEED $speed\r\n';
  }
}

/// 数据编码扩展
extension ListIntExtension on List<int> {
  Uint8List toBytes() {
    return Uint8List.fromList(this);
  }
}
