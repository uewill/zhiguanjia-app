import '../../core/contracts/order_contracts.dart';

/// 统一单据明细模型 - 适用于所有单据类型
class OrderItem implements IOrderItem {
  @override
  final int? id;
  @override
  final int productId;
  @override
  final String productName;
  @override
  final String? productCode;
  @override
  final String? barcode;
  @override
  final String unit;
  @override
  double quantity;
  @override
  double? price;
  @override
  double? amount;
  
  // 扩展字段
  final int? warehouseId;
  final String? warehouseName;
  final int? sourceWarehouseId;
  final int? targetWarehouseId;
  final String? batchNo;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? remark;

  OrderItem({
    this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.barcode,
    this.unit = '件',
    required this.quantity,
    this.price,
    this.amount,
    this.warehouseId,
    this.warehouseName,
    this.sourceWarehouseId,
    this.targetWarehouseId,
    this.batchNo,
    this.productionDate,
    this.expiryDate,
    this.remark,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'productCode': productCode,
    'barcode': barcode,
    'unit': unit,
    'quantity': quantity,
    'price': price,
    'amount': amount ?? (quantity * (price ?? 0)),
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'sourceWarehouseId': sourceWarehouseId,
    'targetWarehouseId': targetWarehouseId,
    'batchNo': batchNo,
    'productionDate': productionDate?.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'remark': remark,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    productId: json['productId'],
    productName: json['productName'],
    productCode: json['productCode'],
    barcode: json['barcode'],
    unit: json['unit'] ?? '件',
    quantity: (json['quantity'] as num).toDouble(),
    price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    warehouseId: json['warehouseId'],
    warehouseName: json['warehouseName'],
    sourceWarehouseId: json['sourceWarehouseId'],
    targetWarehouseId: json['targetWarehouseId'],
    batchNo: json['batchNo'],
    productionDate: json['productionDate'] != null 
        ? DateTime.parse(json['productionDate']) 
        : null,
    expiryDate: json['expiryDate'] != null 
        ? DateTime.parse(json['expiryDate']) 
        : null,
    remark: json['remark'],
  );

  OrderItem copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productCode,
    String? barcode,
    String? unit,
    double? quantity,
    double? price,
    double? amount,
    int? warehouseId,
    String? warehouseName,
    int? sourceWarehouseId,
    int? targetWarehouseId,
    String? batchNo,
    DateTime? productionDate,
    DateTime? expiryDate,
    String? remark,
  }) => OrderItem(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    productCode: productCode ?? this.productCode,
    barcode: barcode ?? this.barcode,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    amount: amount ?? this.amount,
    warehouseId: warehouseId ?? this.warehouseId,
    warehouseName: warehouseName ?? this.warehouseName,
    sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
    targetWarehouseId: targetWarehouseId ?? this.targetWarehouseId,
    batchNo: batchNo ?? this.batchNo,
    productionDate: productionDate ?? this.productionDate,
    expiryDate: expiryDate ?? this.expiryDate,
    remark: remark ?? this.remark,
  );
}

/// 统一单据模型 - 适用于所有单据类型
class UnifiedOrder implements IOrder {
  @override
  final int? id;
  @override
  final String orderNo;
  @override
  final OrderType orderType;
  @override
  final OrderStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;
  @override
  final String? remark;
  
  // 业务字段
  final int? warehouseId;
  final String? warehouseName;
  final int? sourceWarehouseId;
  final String? sourceWarehouseName;
  final int? targetWarehouseId;
  final String? targetWarehouseName;
  final int? partnerId;
  final String? partnerName;
  final int? operatorId;
  final String? operatorName;
  final DateTime? businessDate;
  final DateTime? expectedDate;
  
  // 金额字段
  @override
  final double totalAmount;
  final double? taxAmount;
  final double? discountAmount;
  final double? payableAmount;
  final double? paidAmount;
  
  // 明细
  @override
  final List<OrderItem> items;

  UnifiedOrder({
    this.id,
    required this.orderNo,
    required this.orderType,
    this.status = OrderStatus.draft,
    required this.createdAt,
    this.completedAt,
    this.remark,
    this.warehouseId,
    this.warehouseName,
    this.sourceWarehouseId,
    this.sourceWarehouseName,
    this.targetWarehouseId,
    this.targetWarehouseName,
    this.partnerId,
    this.partnerName,
    this.operatorId,
    this.operatorName,
    this.businessDate,
    this.expectedDate,
    this.totalAmount = 0,
    this.taxAmount,
    this.discountAmount,
    this.payableAmount,
    this.paidAmount,
    this.items = const [],
  });

  @override
  int get itemCount => items.length;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNo': orderNo,
    'orderType': orderType.code,
    'status': status.code,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'remark': remark,
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'sourceWarehouseId': sourceWarehouseId,
    'sourceWarehouseName': sourceWarehouseName,
    'targetWarehouseId': targetWarehouseId,
    'targetWarehouseName': targetWarehouseName,
    'partnerId': partnerId,
    'partnerName': partnerName,
    'operatorId': operatorId,
    'operatorName': operatorName,
    'businessDate': businessDate?.toIso8601String(),
    'expectedDate': expectedDate?.toIso8601String(),
    'totalAmount': totalAmount,
    'taxAmount': taxAmount,
    'discountAmount': discountAmount,
    'payableAmount': payableAmount,
    'paidAmount': paidAmount,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory UnifiedOrder.fromJson(Map<String, dynamic> json) => UnifiedOrder(
    id: json['id'],
    orderNo: json['orderNo'],
    orderType: OrderType.fromCode(json['orderType'] ?? 'sale'),
    status: OrderStatus.fromCode(json['status'] ?? 'draft'),
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt']) 
        : null,
    remark: json['remark'],
    warehouseId: json['warehouseId'],
    warehouseName: json['warehouseName'],
    sourceWarehouseId: json['sourceWarehouseId'],
    sourceWarehouseName: json['sourceWarehouseName'],
    targetWarehouseId: json['targetWarehouseId'],
    targetWarehouseName: json['targetWarehouseName'],
    partnerId: json['partnerId'],
    partnerName: json['partnerName'],
    operatorId: json['operatorId'],
    operatorName: json['operatorName'],
    businessDate: json['businessDate'] != null 
        ? DateTime.parse(json['businessDate']) 
        : null,
    expectedDate: json['expectedDate'] != null 
        ? DateTime.parse(json['expectedDate']) 
        : null,
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    taxAmount: json['taxAmount'] != null ? (json['taxAmount'] as num).toDouble() : null,
    discountAmount: json['discountAmount'] != null 
        ? (json['discountAmount'] as num).toDouble() 
        : null,
    payableAmount: json['payableAmount'] != null 
        ? (json['payableAmount'] as num).toDouble() 
        : null,
    paidAmount: json['paidAmount'] != null ? (json['paidAmount'] as num).toDouble() : null,
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );

  UnifiedOrder copyWith({
    int? id,
    String? orderNo,
    OrderType? orderType,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? remark,
    int? warehouseId,
    String? warehouseName,
    int? sourceWarehouseId,
    String? sourceWarehouseName,
    int? targetWarehouseId,
    String? targetWarehouseName,
    int? partnerId,
    String? partnerName,
    int? operatorId,
    String? operatorName,
    DateTime? businessDate,
    DateTime? expectedDate,
    double? totalAmount,
    double? taxAmount,
    double? discountAmount,
    double? payableAmount,
    double? paidAmount,
    List<OrderItem>? items,
  }) => UnifiedOrder(
    id: id ?? this.id,
    orderNo: orderNo ?? this.orderNo,
    orderType: orderType ?? this.orderType,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt ?? this.completedAt,
    remark: remark ?? this.remark,
    warehouseId: warehouseId ?? this.warehouseId,
    warehouseName: warehouseName ?? this.warehouseName,
    sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
    sourceWarehouseName: sourceWarehouseName ?? this.sourceWarehouseName,
    targetWarehouseId: targetWarehouseId ?? this.targetWarehouseId,
    targetWarehouseName: targetWarehouseName ?? this.targetWarehouseName,
    partnerId: partnerId ?? this.partnerId,
    partnerName: partnerName ?? this.partnerName,
    operatorId: operatorId ?? this.operatorId,
    operatorName: operatorName ?? this.operatorName,
    businessDate: businessDate ?? this.businessDate,
    expectedDate: expectedDate ?? this.expectedDate,
    totalAmount: totalAmount ?? this.totalAmount,
    taxAmount: taxAmount ?? this.taxAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    payableAmount: payableAmount ?? this.payableAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    items: items ?? this.items,
  );

  /// 更新状态
  UnifiedOrder withStatus(OrderStatus newStatus) {
    return copyWith(
      status: newStatus,
      completedAt: newStatus == OrderStatus.completed ? DateTime.now() : completedAt,
    );
  }
}
