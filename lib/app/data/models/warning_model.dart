// 库存预警模型
class InventoryWarning {
  final String id;
  final int productId;
  final String productName;
  final String? skuSpec;
  final int warningType;
  final String warningTypeName;
  final int currentStock;
  final int thresholdValue;
  final String? warehouseName;
  final bool isRead;
  final DateTime createTime;

  InventoryWarning({
    required this.id,
    required this.productId,
    required this.productName,
    this.skuSpec,
    required this.warningType,
    required this.warningTypeName,
    required this.currentStock,
    required this.thresholdValue,
    this.warehouseName,
    this.isRead = false,
    required this.createTime,
  });

  factory InventoryWarning.fromJson(Map<String, dynamic> json) {
    return InventoryWarning(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      skuSpec: json['skuSpec'],
      warningType: json['warningType'],
      warningTypeName: json['warningTypeName'],
      currentStock: json['currentStock'],
      thresholdValue: json['thresholdValue'],
      warehouseName: json['warehouseName'],
      isRead: json['isRead'] ?? false,
      createTime: DateTime.parse(json['createTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'skuSpec': skuSpec,
      'warningType': warningType,
      'warningTypeName': warningTypeName,
      'currentStock': currentStock,
      'thresholdValue': thresholdValue,
      'warehouseName': warehouseName,
      'isRead': isRead,
      'createTime': createTime.toIso8601String(),
    };
  }
}

// 预警类型
class WarningType {
  static const int lowStock = 1;      // 库存不足
  static const int highStock = 2;     // 库存积压
  static const int expiry = 3;        // 临期预警
  static const int stagnant = 4;      // 滞销预警

  static String getName(int type) {
    switch (type) {
      case lowStock: return '库存不足';
      case highStock: return '库存积压';
      case expiry: return '临期预警';
      case stagnant: return '滞销预警';
      default: return '未知';
    }
  }

  static int getColor(int type) {
    switch (type) {
      case lowStock: return 0xFFFF4D4F;     // 红色
      case highStock: return 0xFFFF9500;    // 橙色
      case expiry: return 0xFF1890FF;       // 蓝色
      case stagnant: return 0xFF722ED1;     // 紫色
      default: return 0xFF999999;
    }
  }
}

// 预警设置
class WarningSetting {
  final int productId;
  final int? minStock;          // 最低库存
  final int? maxStock;          // 最高库存
  final int? expiryDays;        // 临期天数
  final int? stagnantDays;      // 滞销天数
  final bool isEnabled;
  final DateTime updateTime;

  WarningSetting({
    required this.productId,
    this.minStock,
    this.maxStock,
    this.expiryDays,
    this.stagnantDays,
    this.isEnabled = true,
    required this.updateTime,
  });

  factory WarningSetting.fromJson(Map<String, dynamic> json) {
    return WarningSetting(
      productId: json['productId'],
      minStock: json['minStock'],
      maxStock: json['maxStock'],
      expiryDays: json['expiryDays'],
      stagnantDays: json['stagnantDays'],
      isEnabled: json['isEnabled'] ?? true,
      updateTime: DateTime.parse(json['updateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'minStock': minStock,
      'maxStock': maxStock,
      'expiryDays': expiryDays,
      'stagnantDays': stagnantDays,
      'isEnabled': isEnabled,
      'updateTime': updateTime.toIso8601String(),
    };
  }
}
