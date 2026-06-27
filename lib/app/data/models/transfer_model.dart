// 调拨单
class TransferOrder {
  final int id;
  final String orderNo;
  final int fromWarehouseId;
  final String fromWarehouseName;
  final int toWarehouseId;
  final String toWarehouseName;
  final String status; // pending, completed, cancelled
  final int itemCount;
  final double totalAmount;
  final String? remark;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<TransferItem>? items;

  TransferOrder({
    required this.id,
    required this.orderNo,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.status,
    required this.itemCount,
    required this.totalAmount,
    this.remark,
    required this.createdAt,
    this.completedAt,
    this.items,
  });

  factory TransferOrder.fromJson(Map<String, dynamic> json) {
    return TransferOrder(
      id: json['id'],
      orderNo: json['orderNo'],
      fromWarehouseId: json['fromWarehouseId'],
      fromWarehouseName: json['fromWarehouseName'] ?? '',
      toWarehouseId: json['toWarehouseId'],
      toWarehouseName: json['toWarehouseName'] ?? '',
      status: json['status'],
      itemCount: json['itemCount'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      remark: json['remark'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => TransferItem.fromJson(e)).toList()
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待调拨';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }
}

// 调拨明细
class TransferItem {
  final int id;
  final int productId;
  final String productName;
  final String? productCode;
  final String? barcode;
  final String? unit;
  int quantity;
  final double? purchasePrice;
  double? totalPrice;
  String? remark;

  TransferItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.barcode,
    this.unit,
    required this.quantity,
    this.purchasePrice,
    this.totalPrice,
    this.remark,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) {
    return TransferItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productCode: json['productCode'],
      barcode: json['barcode'],
      unit: json['unit'],
      quantity: json['quantity'] ?? 0,
      purchasePrice: json['purchasePrice'] != null ? (json['purchasePrice'] as num).toDouble() : null,
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : null,
      remark: json['remark'],
    );
  }
}
