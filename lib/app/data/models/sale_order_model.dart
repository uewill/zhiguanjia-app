// 销售订单
class SaleOrder {
  final int id;
  final String orderNo;
  final int? customerId;
  final String? customerName;
  final int warehouseId;
  final String warehouseName;
  final String status; // pending, approved, partially_delivered, completed, cancelled
  final int itemCount;
  final double totalAmount;
  final double? paidAmount;
  final String? remark;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<SaleOrderItem>? items;

  SaleOrder({
    required this.id,
    required this.orderNo,
    this.customerId,
    this.customerName,
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

  factory SaleOrder.fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      id: json['id'],
      orderNo: json['orderNo'],
      customerId: json['customerId'],
      customerName: json['customerName'],
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
          ? (json['items'] as List).map((e) => SaleOrderItem.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'customerId': customerId,
      'customerName': customerName,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'status': status,
      'itemCount': itemCount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remark': remark,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待审核';
      case 'approved':
        return '已审核';
      case 'partially_delivered':
        return '部分出库';
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

// 销售订单明细
class SaleOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productCode;
  final String? barcode;
  final String? unit;
  int quantity;
  double price;
  double? totalPrice;
  int? deliveredQuantity;
  String? remark;

  SaleOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.barcode,
    this.unit,
    required this.quantity,
    required this.price,
    this.totalPrice,
    this.deliveredQuantity,
    this.remark,
  });

  factory SaleOrderItem.fromJson(Map<String, dynamic> json) {
    return SaleOrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productCode: json['productCode'],
      barcode: json['barcode'],
      unit: json['unit'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : null,
      deliveredQuantity: json['deliveredQuantity'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'barcode': barcode,
      'unit': unit,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice ?? (price * quantity),
      'deliveredQuantity': deliveredQuantity,
      'remark': remark,
    };
  }

  int get pendingQuantity => quantity - (deliveredQuantity ?? 0);
}
