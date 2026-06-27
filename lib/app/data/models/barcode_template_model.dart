/// 条码打印模版模型
class BarcodeTemplate {
  final String id;
  final String name;
  final BarcodeTemplateType type;
  final String description;
  final BarcodeLabelSize labelSize;
  final List<BarcodeElement> elements;
  final bool isDefault;
  final bool isEnabled;
  final DateTime createTime;
  final DateTime updateTime;

  BarcodeTemplate({
    required this.id,
    required this.name,
    required this.type,
    this.description = '',
    required this.labelSize,
    required this.elements,
    this.isDefault = false,
    this.isEnabled = true,
    required this.createTime,
    required this.updateTime,
  });

  factory BarcodeTemplate.fromJson(Map<String, dynamic> json) {
    return BarcodeTemplate(
      id: json['id'],
      name: json['name'],
      type: BarcodeTemplateType.fromString(json['type']),
      description: json['description'] ?? '',
      labelSize: BarcodeLabelSize.fromJson(json['labelSize']),
      elements: (json['elements'] as List)
          .map((e) => BarcodeElement.fromJson(e))
          .toList(),
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
      'type': type.value,
      'description': description,
      'labelSize': labelSize.toJson(),
      'elements': elements.map((e) => e.toJson()).toList(),
      'isDefault': isDefault,
      'isEnabled': isEnabled,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  BarcodeTemplate copyWith({
    String? id,
    String? name,
    BarcodeTemplateType? type,
    String? description,
    BarcodeLabelSize? labelSize,
    List<BarcodeElement>? elements,
    bool? isDefault,
    bool? isEnabled,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return BarcodeTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      labelSize: labelSize ?? this.labelSize,
      elements: elements ?? this.elements,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}

/// 条码模版类型
enum BarcodeTemplateType {
  single,      // 单个商品条码
  sheet,       // 多排条码页
  priceTag,    // 价格标签
  shelfTag,    // 货架标签
  ;

  String get value {
    switch (this) {
      case BarcodeTemplateType.single:
        return 'single';
      case BarcodeTemplateType.sheet:
        return 'sheet';
      case BarcodeTemplateType.priceTag:
        return 'priceTag';
      case BarcodeTemplateType.shelfTag:
        return 'shelfTag';
    }
  }

  String get displayName {
    switch (this) {
      case BarcodeTemplateType.single:
        return '单个条码';
      case BarcodeTemplateType.sheet:
        return '多排条码';
      case BarcodeTemplateType.priceTag:
        return '价格标签';
      case BarcodeTemplateType.shelfTag:
        return '货架标签';
    }
  }

  static BarcodeTemplateType fromString(String value) {
    switch (value) {
      case 'single':
        return BarcodeTemplateType.single;
      case 'sheet':
        return BarcodeTemplateType.sheet;
      case 'priceTag':
        return BarcodeTemplateType.priceTag;
      case 'shelfTag':
        return BarcodeTemplateType.shelfTag;
      default:
        return BarcodeTemplateType.single;
    }
  }
}

/// 标签尺寸
class BarcodeLabelSize {
  final double width;      // mm
  final double height;     // mm
  final double? gap;       // 标签间隙 mm
  final int? columns;      // 每行列数 (sheet 模式)
  final int? rows;         // 每页行数 (sheet 模式)

  BarcodeLabelSize({
    required this.width,
    required this.height,
    this.gap,
    this.columns,
    this.rows,
  });

  factory BarcodeLabelSize.fromJson(Map<String, dynamic> json) {
    return BarcodeLabelSize(
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      gap: json['gap']?.toDouble(),
      columns: json['columns'],
      rows: json['rows'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'gap': gap,
      'columns': columns,
      'rows': rows,
    };
  }

  // 预设标签尺寸
  static BarcodeLabelSize get standard30x20 => BarcodeLabelSize(
        width: 30,
        height: 20,
        gap: 2,
      );

  static BarcodeLabelSize get standard40x30 => BarcodeLabelSize(
        width: 40,
        height: 30,
        gap: 2,
      );

  static BarcodeLabelSize get standard50x30 => BarcodeLabelSize(
        width: 50,
        height: 30,
        gap: 2,
      );

  static BarcodeLabelSize get standard50x40 => BarcodeLabelSize(
        width: 50,
        height: 40,
        gap: 2,
      );

  static BarcodeLabelSize get a4Sheet2x5 => BarcodeLabelSize(
        width: 40,
        height: 30,
        gap: 2,
        columns: 2,
        rows: 5,
      );

  static BarcodeLabelSize get a4Sheet3x7 => BarcodeLabelSize(
        width: 30,
        height: 20,
        gap: 2,
        columns: 3,
        rows: 7,
      );

  static List<BarcodeLabelSize> get presets => [
        standard30x20,
        standard40x30,
        standard50x30,
        standard50x40,
        a4Sheet2x5,
        a4Sheet3x7,
      ];
}

/// 条码模版元素
class BarcodeElement {
  final String id;
  final BarcodeElementType type;
  final String field;           // 字段名
  final String? customText;     // 自定义文本
  final double x;               // mm
  final double y;               // mm
  final BarcodeElementStyle style;

  BarcodeElement({
    required this.id,
    required this.type,
    this.field = '',
    this.customText,
    required this.x,
    required this.y,
    required this.style,
  });

  factory BarcodeElement.fromJson(Map<String, dynamic> json) {
    return BarcodeElement(
      id: json['id'],
      type: BarcodeElementType.fromString(json['type']),
      field: json['field'] ?? '',
      customText: json['customText'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      style: BarcodeElementStyle.fromJson(json['style']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'field': field,
      'customText': customText,
      'x': x,
      'y': y,
      'style': style.toJson(),
    };
  }

  BarcodeElement copyWith({
    String? id,
    BarcodeElementType? type,
    String? field,
    String? customText,
    double? x,
    double? y,
    BarcodeElementStyle? style,
  }) {
    return BarcodeElement(
      id: id ?? this.id,
      type: type ?? this.type,
      field: field ?? this.field,
      customText: customText ?? this.customText,
      x: x ?? this.x,
      y: y ?? this.y,
      style: style ?? this.style,
    );
  }
}

/// 条码元素类型
enum BarcodeElementType {
  barcode,     // 一维条码
  qrcode,      // 二维码
  text,        // 文本
  productName, // 商品名称
  productSpec, // 商品规格
  price,       // 价格
  line,        // 直线
  box,         // 方框
  logo,        // Logo
  ;

  String get value {
    switch (this) {
      case BarcodeElementType.barcode:
        return 'barcode';
      case BarcodeElementType.qrcode:
        return 'qrcode';
      case BarcodeElementType.text:
        return 'text';
      case BarcodeElementType.productName:
        return 'productName';
      case BarcodeElementType.productSpec:
        return 'productSpec';
      case BarcodeElementType.price:
        return 'price';
      case BarcodeElementType.line:
        return 'line';
      case BarcodeElementType.box:
        return 'box';
      case BarcodeElementType.logo:
        return 'logo';
    }
  }

  String get displayName {
    switch (this) {
      case BarcodeElementType.barcode:
        return '一维条码';
      case BarcodeElementType.qrcode:
        return '二维码';
      case BarcodeElementType.text:
        return '文本';
      case BarcodeElementType.productName:
        return '商品名称';
      case BarcodeElementType.productSpec:
        return '商品规格';
      case BarcodeElementType.price:
        return '价格';
      case BarcodeElementType.line:
        return '分隔线';
      case BarcodeElementType.box:
        return '边框';
      case BarcodeElementType.logo:
        return 'Logo';
    }
  }

  static BarcodeElementType fromString(String value) {
    switch (value) {
      case 'barcode':
        return BarcodeElementType.barcode;
      case 'qrcode':
        return BarcodeElementType.qrcode;
      case 'text':
        return BarcodeElementType.text;
      case 'productName':
        return BarcodeElementType.productName;
      case 'productSpec':
        return BarcodeElementType.productSpec;
      case 'price':
        return BarcodeElementType.price;
      case 'line':
        return BarcodeElementType.line;
      case 'box':
        return BarcodeElementType.box;
      case 'logo':
        return BarcodeElementType.logo;
      default:
        return BarcodeElementType.text;
    }
  }
}

/// 条码元素样式
class BarcodeElementStyle {
  final double fontSize;        // 字体大小 (pt)
  final bool isBold;
  final String align;           // left, center, right
  final int rotation;           // 0, 90, 180, 270
  final double width;           // 宽度 mm (用于条码、线条)
  final double height;          // 高度 mm (用于条码、线条)

  BarcodeElementStyle({
    this.fontSize = 10,
    this.isBold = false,
    this.align = 'left',
    this.rotation = 0,
    this.width = 0,
    this.height = 0,
  });

  factory BarcodeElementStyle.fromJson(Map<String, dynamic> json) {
    return BarcodeElementStyle(
      fontSize: json['fontSize']?.toDouble() ?? 10,
      isBold: json['isBold'] ?? false,
      align: json['align'] ?? 'left',
      rotation: json['rotation'] ?? 0,
      width: json['width']?.toDouble() ?? 0,
      height: json['height']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'isBold': isBold,
      'align': align,
      'rotation': rotation,
      'width': width,
      'height': height,
    };
  }

  BarcodeElementStyle copyWith({
    double? fontSize,
    bool? isBold,
    String? align,
    int? rotation,
    double? width,
    double? height,
  }) {
    return BarcodeElementStyle(
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      align: align ?? this.align,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// 条码字段常量
class BarcodeFields {
  static const String barcode = 'barcode';
  static const String productName = 'productName';
  static const String productSpec = 'productSpec';
  static const String productCode = 'productCode';
  static const String salePrice = 'salePrice';
  static const String costPrice = 'costPrice';
  static const String category = 'category';
  static const String unit = 'unit';
}
