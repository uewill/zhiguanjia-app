// 盘点单
class StockCheckOrder {
  final int id;
  final String orderNo;
  final int warehouseId;
  final String warehouseName;
  final String status; // pending, checking, completed, cancelled
  final int itemCount;
  final int? profitCount;
  final int? lossCount;
  final double? profitAmount;
  final double? lossAmount;
  final String? remark;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<StockCheckItem>? items;

  StockCheckOrder({
    required this.id,
    required this.orderNo,
    required this.warehouseId,
    required this.warehouseName,
    required this.status,
    required this.itemCount,
    this.profitCount,
    this.lossCount,
    this.profitAmount,
    this.lossAmount,
    this.remark,
    required this.createdAt,
    this.completedAt,
    this.items,
  });

  factory StockCheckOrder.fromJson(Map<String, dynamic> json) {
    return StockCheckOrder(
      id: json['id'],
      orderNo: json['orderNo'],
      warehouseId: json['warehouseId'],
      warehouseName: json['warehouseName'] ?? '',
      status: json['status'],
      itemCount: json['itemCount'] ?? 0,
      profitCount: json['profitCount'],
      lossCount: json['lossCount'],
      profitAmount: json['profitAmount'] != null ? (json['profitAmount'] as num).toDouble() : null,
      lossAmount: json['lossAmount'] != null ? (json['lossAmount'] as num).toDouble() : null,
      remark: json['remark'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => StockCheckItem.fromJson(e)).toList()
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待盘点';
      case 'checking':
        return '盘点中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }
}

// 盘点明细
class StockCheckItem {
  final int id;
  final int productId;
  final String productName;
  final String? productCode;
  final String? barcode;
  final String? unit;
  final int systemStock;
  int checkStock;
  final double? purchasePrice;
  String? remark;

  StockCheckItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.barcode,
    this.unit,
    required this.systemStock,
    required this.checkStock,
    this.purchasePrice,
    this.remark,
  });

  factory StockCheckItem.fromJson(Map<String, dynamic> json) {
    return StockCheckItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productCode: json['productCode'],
      barcode: json['barcode'],
      unit: json['unit'],
      systemStock: json['systemStock'] ?? 0,
      checkStock: json['checkStock'] ?? 0,
      purchasePrice: json['purchasePrice'] != null ? (json['purchasePrice'] as num).toDouble() : null,
      remark: json['remark'],
    );
  }

  // 盘盈盘亏
  int get diff => checkStock - systemStock;
  double? get diffAmount => purchasePrice != null ? diff * purchasePrice! : null;
  bool get isProfit => diff > 0;
  bool get isLoss => diff < 0;
}
