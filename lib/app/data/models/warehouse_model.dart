class Warehouse {
  final int id;
  final String name;
  final String? code;
  final String? address;
  final String? contact;
  final String? phone;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;

  Warehouse({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.contact,
    this.phone,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      contact: json['contact'],
      phone: json['phone'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'contact': contact,
      'phone': phone,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// 商品仓库库存
class ProductWarehouseStock {
  final int id;
  final int productId;
  final int warehouseId;
  final String warehouseName;
  final int stock;
  final int? minStock;

  ProductWarehouseStock({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.warehouseName,
    required this.stock,
    this.minStock,
  });

  factory ProductWarehouseStock.fromJson(Map<String, dynamic> json) {
    return ProductWarehouseStock(
      id: json['id'],
      productId: json['productId'],
      warehouseId: json['warehouseId'],
      warehouseName: json['warehouseName'] ?? '',
      stock: json['stock'] ?? 0,
      minStock: json['minStock'],
    );
  }
}
