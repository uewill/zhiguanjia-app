/// 打印模版模型
class PrintTemplate {
  final String id;
  final String name;
  final String type; // receipt: 小票, delivery: 发货单, invoice: 发票
  final String? description;
  final PaperSize paperSize;
  final List<PrintElement> elements;
  final PrintStyle globalStyle;
  final bool isDefault;
  final bool isEnabled;
  final DateTime createTime;
  final DateTime updateTime;

  PrintTemplate({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.paperSize,
    required this.elements,
    required this.globalStyle,
    this.isDefault = false,
    this.isEnabled = true,
    required this.createTime,
    required this.updateTime,
  });

  factory PrintTemplate.fromJson(Map<String, dynamic> json) {
    return PrintTemplate(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      paperSize: PaperSize.fromJson(json['paperSize']),
      elements: (json['elements'] as List)
          .map((e) => PrintElement.fromJson(e))
          .toList(),
      globalStyle: PrintStyle.fromJson(json['globalStyle']),
      isDefault: json['isDefault'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'paperSize': paperSize.toJson(),
      'elements': elements.map((e) => e.toJson()).toList(),
      'globalStyle': globalStyle.toJson(),
      'isDefault': isDefault,
      'isEnabled': isEnabled,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  PrintTemplate copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    PaperSize? paperSize,
    List<PrintElement>? elements,
    PrintStyle? globalStyle,
    bool? isDefault,
    bool? isEnabled,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return PrintTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      paperSize: paperSize ?? this.paperSize,
      elements: elements ?? this.elements,
      globalStyle: globalStyle ?? this.globalStyle,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}

/// 纸张尺寸
class PaperSize {
  final String name; // 58mm, 80mm, A4, A5, custom
  final double width; // mm
  final double height; // mm, 0 表示连续纸

  PaperSize({
    required this.name,
    required this.width,
    this.height = 0,
  });

  factory PaperSize.fromJson(Map<String, dynamic> json) {
    return PaperSize(
      name: json['name'],
      width: json['width'].toDouble(),
      height: json['height']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'width': width,
      'height': height,
    };
  }

  // 预定义纸张尺寸
  static PaperSize mm58 = PaperSize(name: '58mm', width: 58);
  static PaperSize mm80 = PaperSize(name: '80mm', width: 80);
  static PaperSize a4 = PaperSize(name: 'A4', width: 210, height: 297);
  static PaperSize a5 = PaperSize(name: 'A5', width: 148, height: 210);
}

/// 打印元素
class PrintElement {
  final String id;
  final String type; // text, image, barcode, qrcode, line, table, space
  final String? field; // 数据字段名
  final String? customText; // 自定义文本
  final PrintStyle style;
  final PrintPosition position;
  final PrintSize size;
  final bool isVisible;

  PrintElement({
    required this.id,
    required this.type,
    this.field,
    this.customText,
    required this.style,
    required this.position,
    required this.size,
    this.isVisible = true,
  });

  factory PrintElement.fromJson(Map<String, dynamic> json) {
    return PrintElement(
      id: json['id'],
      type: json['type'],
      field: json['field'],
      customText: json['customText'],
      style: PrintStyle.fromJson(json['style']),
      position: PrintPosition.fromJson(json['position']),
      size: PrintSize.fromJson(json['size']),
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'field': field,
      'customText': customText,
      'style': style.toJson(),
      'position': position.toJson(),
      'size': size.toJson(),
      'isVisible': isVisible,
    };
  }

  PrintElement copyWith({
    String? id,
    String? type,
    String? field,
    String? customText,
    PrintStyle? style,
    PrintPosition? position,
    PrintSize? size,
    bool? isVisible,
  }) {
    return PrintElement(
      id: id ?? this.id,
      type: type ?? this.type,
      field: field ?? this.field,
      customText: customText ?? this.customText,
      style: style ?? this.style,
      position: position ?? this.position,
      size: size ?? this.size,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// 打印样式
class PrintStyle {
  final String? fontFamily;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final String align; // left, center, right
  final String? color; // 颜色代码

  PrintStyle({
    this.fontFamily,
    this.fontSize = 12,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.align = 'left',
    this.color,
  });

  factory PrintStyle.fromJson(Map<String, dynamic> json) {
    return PrintStyle(
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize']?.toDouble() ?? 12,
      isBold: json['isBold'] ?? false,
      isItalic: json['isItalic'] ?? false,
      isUnderline: json['isUnderline'] ?? false,
      align: json['align'] ?? 'left',
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'align': align,
      'color': color,
    };
  }

  PrintStyle copyWith({
    String? fontFamily,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    String? align,
    String? color,
  }) {
    return PrintStyle(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      align: align ?? this.align,
      color: color ?? this.color,
    );
  }
}

/// 打印位置
class PrintPosition {
  final double x; // mm
  final double y; // mm

  PrintPosition({this.x = 0, this.y = 0});

  factory PrintPosition.fromJson(Map<String, dynamic> json) {
    return PrintPosition(
      x: json['x']?.toDouble() ?? 0,
      y: json['y']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

/// 打印尺寸
class PrintSize {
  final double width; // mm, 0 表示自动
  final double height; // mm, 0 表示自动

  PrintSize({this.width = 0, this.height = 0});

  factory PrintSize.fromJson(Map<String, dynamic> json) {
    return PrintSize(
      width: json['width']?.toDouble() ?? 0,
      height: json['height']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

/// 预定义打印字段
class PrintFields {
  // 店铺信息
  static const String shopName = 'shopName';
  static const String shopAddress = 'shopAddress';
  static const String shopPhone = 'shopPhone';
  static const String shopLogo = 'shopLogo';

  // 订单信息
  static const String orderNo = 'orderNo';
  static const String orderTime = 'orderTime';
  static const String orderType = 'orderType';
  static const String orderStatus = 'orderStatus';

  // 商品信息（表格）
  static const String itemsTable = 'itemsTable';
  static const String itemName = 'itemName';
  static const String itemSpec = 'itemSpec';
  static const String itemQuantity = 'itemQuantity';
  static const String itemPrice = 'itemPrice';
  static const String itemAmount = 'itemAmount';

  // 金额信息
  static const String totalQuantity = 'totalQuantity';
  static const String totalAmount = 'totalAmount';
  static const String discountAmount = 'discountAmount';
  static const String payableAmount = 'payableAmount';
  static const String paidAmount = 'paidAmount';
  static const String changeAmount = 'changeAmount';

  // 支付信息
  static const String paymentMethod = 'paymentMethod';
  static const String paymentTime = 'paymentTime';
  static const String transactionNo = 'transactionNo';

  // 客户信息
  static const String customerName = 'customerName';
  static const String customerPhone = 'customerPhone';
  static const String customerAddress = 'customerAddress';

  // 其他
  static const String remark = 'remark';
  static const String qrcode = 'qrcode';
  static const String barcode = 'barcode';
  static const String printTime = 'printTime';
  static const String cashierName = 'cashierName';
}

/// 打印任务
class PrintJob {
  final String id;
  final String templateId;
  final String documentType; // order, purchase, inventory, etc.
  final String documentId;
  final Map<String, dynamic> data;
  final String status; // pending, processing, completed, failed
  final String? pdfUrl;
  final String? errorMessage;
  final DateTime createTime;
  final DateTime? completeTime;

  PrintJob({
    required this.id,
    required this.templateId,
    required this.documentType,
    required this.documentId,
    required this.data,
    this.status = 'pending',
    this.pdfUrl,
    this.errorMessage,
    required this.createTime,
    this.completeTime,
  });

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      id: json['id'],
      templateId: json['templateId'],
      documentType: json['documentType'],
      documentId: json['documentId'],
      data: json['data'],
      status: json['status'],
      pdfUrl: json['pdfUrl'],
      errorMessage: json['errorMessage'],
      createTime: DateTime.parse(json['createTime']),
      completeTime: json['completeTime'] != null
          ? DateTime.parse(json['completeTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'documentType': documentType,
      'documentId': documentId,
      'data': data,
      'status': status,
      'pdfUrl': pdfUrl,
      'errorMessage': errorMessage,
      'createTime': createTime.toIso8601String(),
      'completeTime': completeTime?.toIso8601String(),
    };
  }
}
