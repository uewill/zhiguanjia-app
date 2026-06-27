class Product {
  final int id;
  final String name;
  final String code;
  final String? barcode;
  final String? category;
  final String unit;
  final List<ProductUnit>? units;
  final double purchasePrice;
  final double salePrice;
  final int stock;
  final int minStock;
  final String? imageUrl;
  final List<String>? images;
  final bool hasSku;
  final List<SkuSpec>? skuSpecs;
  final List<ProductSku>? skus;
  final List<ProductAttr>? attrs;

  Product({
    required this.id,
    required this.name,
    required this.code,
    this.barcode,
    this.category,
    required this.unit,
    this.units,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    required this.minStock,
    this.imageUrl,
    this.images,
    this.hasSku = false,
    this.skuSpecs,
    this.skus,
    this.attrs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      barcode: json['barcode'],
      category: json['category'],
      unit: json['unit'] ?? '瓶',
      units: json['units'] != null ? (json['units'] as List).map((e) => ProductUnit.fromJson(e)).toList() : null,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      stock: json['stock'],
      minStock: json['minStock'] ?? 0,
      imageUrl: json['imageUrl'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      hasSku: json['hasSku'] ?? false,
      skuSpecs: json['skuSpecs'] != null
          ? (json['skuSpecs'] as List).map((e) => SkuSpec.fromJson(e)).toList()
          : null,
      skus: json['skus'] != null ? (json['skus'] as List).map((e) => ProductSku.fromJson(e)).toList() : null,
      attrs: json['attrs'] != null ? (json['attrs'] as List).map((e) => ProductAttr.fromJson(e)).toList() : null,
    );
  }
}

class SkuSpec {
  String name;
  List<String> values;

  SkuSpec({required this.name, required this.values});

  factory SkuSpec.fromJson(Map<String, dynamic> json) {
    return SkuSpec(
      name: json['name'],
      values: List<String>.from(json['values']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
    };
  }
}

// 多单位管理
class ProductUnit {
  String name;
  double ratio;
  double? purchasePrice;
  double? salePrice;
  String? barcode;

  ProductUnit({
    required this.name,
    required this.ratio,
    this.purchasePrice,
    this.salePrice,
    this.barcode,
  });

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      name: json['name'],
      ratio: (json['ratio'] as num).toDouble(),
      purchasePrice: json['purchasePrice'] != null ? (json['purchasePrice'] as num).toDouble() : null,
      salePrice: json['salePrice'] != null ? (json['salePrice'] as num).toDouble() : null,
      barcode: json['barcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ratio': ratio,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'barcode': barcode,
    };
  }
}

// 多规格SKU
class ProductSku {
  String id;
  Map<String, String> specs;
  double purchasePrice;
  double salePrice;
  int stock;
  String? barcode;
  String? imageUrl;

  ProductSku({
    required this.id,
    required this.specs,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    this.barcode,
    this.imageUrl,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      id: json['id'],
      specs: Map<String, String>.from(json['specs']),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      stock: json['stock'],
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specs': specs,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'stock': stock,
      'barcode': barcode,
      'imageUrl': imageUrl,
    };
  }

  String get specText => specs.entries.map((e) => '${e.key}:${e.value}').join(' ');
}

// 自定义属性
class ProductAttr {
  String name;
  String value;

  ProductAttr({required this.name, required this.value});

  factory ProductAttr.fromJson(Map<String, dynamic> json) {
    return ProductAttr(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
