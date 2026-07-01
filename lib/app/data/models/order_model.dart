class Order {
  final int id;
  final String orderNo;
  final String type; // 'purchase' or 'sale'
  final int customerId;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final int status;
  final String? remark;
  final DateTime createTime;

  Order({
    required this.id,
    required this.orderNo,
    this.type = 'sale',
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.status,
    this.remark,
    required this.createTime,
  });
  
  // 兼容性getter，用于订单列表显示
  double get amount => totalAmount;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNo: json['orderNo'],
      type: json['type'] ?? 'sale',
      customerId: json['customerId'],
      customerName: json['customerName'],
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      status: json['status'],
      remark: json['remark'],
      createTime: DateTime.parse(json['createTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'type': type,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'status': status,
      'remark': remark,
      'createTime': createTime.toIso8601String(),
    };
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final String? barcode;          // 商品条码
  final int quantity;
  final String unit;
  final double unitPrice;
  final double amount;
  
  // 多单位/多规格扩展
  final double? unitRatio;      // 单位转换比例
  final String? skuId;          // SKU ID
  final Map<String, String>? skuSpecs;  // 规格组合
  final int? actualQuantity;    // 实际库存扣减数量

  OrderItem({
    required this.productId,
    required this.productName,
    this.barcode,               // 可选条码
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.amount,
    this.unitRatio,
    this.skuId,
    this.skuSpecs,
    this.actualQuantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      barcode: json['barcode'],  // 解析条码
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      unitRatio: json['unitRatio'] != null ? (json['unitRatio'] as num).toDouble() : null,
      skuId: json['skuId'],
      skuSpecs: json['skuSpecs'] != null ? Map<String, String>.from(json['skuSpecs']) : null,
      actualQuantity: json['actualQuantity'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'barcode': barcode,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'amount': amount,
      'unitRatio': unitRatio,
      'skuId': skuId,
      'skuSpecs': skuSpecs,
      'actualQuantity': actualQuantity,
    };
  }
  
  // 获取显示名称（包含规格信息）
  String get displayName {
    if (skuSpecs != null && skuSpecs!.isNotEmpty) {
      final specText = skuSpecs!.entries.map((e) => '${e.key}:${e.value}').join(' ');
      return '$productName ($specText)';
    }
    return productName;
  }
  
  // 是否为多规格商品
  bool get isMultiSku => skuId != null;
  
  // 是否为多单位商品
  bool get isMultiUnit => unitRatio != null && unitRatio != 1.0;
}
