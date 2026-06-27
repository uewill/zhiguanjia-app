import '../../../../app/core/data/index.dart';

/// 商品数据模型
class ProductModel implements DataItem {
  @override
  final int? id;
  @override
  final String name;
  @override
  final String? code;
  @override
  final bool isActive;
  
  final String? barcode;
  final String? categoryId;
  final String? categoryName;
  final String? unit;
  final String? unitId;
  final double? purchasePrice;
  final double? salePrice;
  final double? stock;
  final double? minStock;
  final double? maxStock;
  final String? remark;
  final List<String>? images;

  ProductModel({
    this.id,
    required this.name,
    this.code,
    this.barcode,
    this.categoryId,
    this.categoryName,
    this.unit,
    this.unitId,
    this.purchasePrice,
    this.salePrice,
    this.stock,
    this.minStock,
    this.maxStock,
    this.remark,
    this.images,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      barcode: json['barcode'],
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName'],
      unit: json['unit'],
      unitId: json['unitId']?.toString(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toDouble(),
      minStock: (json['minStock'] as num?)?.toDouble(),
      maxStock: (json['maxStock'] as num?)?.toDouble(),
      remark: json['remark'],
      images: json['images'] != null 
        ? List<String>.from(json['images']) 
        : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'barcode': barcode,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'unit': unit,
    'unitId': unitId,
    'purchasePrice': purchasePrice,
    'salePrice': salePrice,
    'stock': stock,
    'minStock': minStock,
    'maxStock': maxStock,
    'remark': remark,
    'images': images,
    'isActive': isActive,
  };

  /// 计算毛利率
  double? get profitMargin {
    if (purchasePrice == null || salePrice == null || purchasePrice == 0) {
      return null;
    }
    return ((salePrice! - purchasePrice!) / salePrice! * 100);
  }

  /// 是否库存不足
  bool get isLowStock => minStock != null && stock != null && stock! < minStock!;

  /// 是否库存过剩
  bool get isOverStock => maxStock != null && stock != null && stock! > maxStock!;
}