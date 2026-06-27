// 采购订单
class PurchaseOrder {
  final int id;
  final String orderNo;
  final int? supplierId;
  final String? supplierName;
  final int warehouseId;
  final String warehouseName;
  final String status; // pending, approved, partially_received, completed, cancelled
  final int itemCount;
  final double totalAmount;
  final double? paidAmount;
  final String? remark;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<PurchaseOrderItem>? items;

  PurchaseOrder({
    required this.id,
    required this.orderNo,
    this.supplierId,
    this.supplierName,
    required this.warehouseId,
    required this.warehouseName,
    required this.status,
    required this.itemCount,
    required this.totalAmount,
    this.paidAmount,
    this.remark,
    required this.orderDate,
    this.deliveryDate,
    required this.createdAt,
    this.completedAt,
    this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      orderNo: json['orderNo'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      warehouseId: json['warehouseId'],
      warehouseName: json['warehouseName'] ?? '',
      status: json['status'],
      itemCount: json['itemCount'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: json['paidAmount'] != null ? (json['paidAmount'] as num).toDouble() : null,
      remark: json['remark'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => PurchaseOrderItem.fromJson(e)).toList()
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待审核';
      case 'approved':
        return '已审核';
      case 'partially_received':
        return '部分入库';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  double get unpaidAmount => totalAmount - (paidAmount ?? 0);
}

// 采购订单明细
class PurchaseOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productCode;
  final String? barcode;
  final String? unit;
  int quantity;
  double price;
  double? totalPrice;
  int? receivedQuantity;
  String? remark;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.barcode,
    this.unit,
    required this.quantity,
    required this.price,
    this.totalPrice,
    this.receivedQuantity,
    this.remark,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productCode: json['productCode'],
      barcode: json['barcode'],
      unit: json['unit'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : null,
      receivedQuantity: json['receivedQuantity'],
      remark: json['remark'],
    );
  }

  int get pendingQuantity => quantity - (receivedQuantity ?? 0);
}
