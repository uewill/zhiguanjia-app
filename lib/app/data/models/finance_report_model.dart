// 财务报表模型
class FinanceReport {
  final DateTime startDate;
  final DateTime endDate;
  final SalesSummary salesSummary;
  final PurchaseSummary purchaseSummary;
  final ProfitSummary profitSummary;
  final List<PaymentItem> payments;
  final List<ReceivableItem> receivables;

  FinanceReport({
    required this.startDate,
    required this.endDate,
    required this.salesSummary,
    required this.purchaseSummary,
    required this.profitSummary,
    required this.payments,
    required this.receivables,
  });

  factory FinanceReport.fromJson(Map<String, dynamic> json) {
    return FinanceReport(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      salesSummary: SalesSummary.fromJson(json['salesSummary']),
      purchaseSummary: PurchaseSummary.fromJson(json['purchaseSummary']),
      profitSummary: ProfitSummary.fromJson(json['profitSummary']),
      payments: (json['payments'] as List).map((e) => PaymentItem.fromJson(e)).toList(),
      receivables: (json['receivables'] as List).map((e) => ReceivableItem.fromJson(e)).toList(),
    );
  }
}

// 销售汇总
class SalesSummary {
  final int orderCount;
  final double totalAmount;
  final double discountAmount;
  final double netAmount;
  final double receivedAmount;
  final double unreceivedAmount;

  SalesSummary({
    required this.orderCount,
    required this.totalAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.receivedAmount,
    required this.unreceivedAmount,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      orderCount: json['orderCount'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      receivedAmount: (json['receivedAmount'] as num).toDouble(),
      unreceivedAmount: (json['unreceivedAmount'] as num).toDouble(),
    );
  }
}

// 采购汇总
class PurchaseSummary {
  final int orderCount;
  final double totalAmount;
  final double paidAmount;
  final double unpaidAmount;

  PurchaseSummary({
    required this.orderCount,
    required this.totalAmount,
    required this.paidAmount,
    required this.unpaidAmount,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseSummary(
      orderCount: json['orderCount'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      unpaidAmount: (json['unpaidAmount'] as num).toDouble(),
    );
  }
}

// 利润汇总
class ProfitSummary {
  final double grossProfit;
  final double grossMargin;
  final double operatingCost;
  final double netProfit;

  ProfitSummary({
    required this.grossProfit,
    required this.grossMargin,
    required this.operatingCost,
    required this.netProfit,
  });

  factory ProfitSummary.fromJson(Map<String, dynamic> json) {
    return ProfitSummary(
      grossProfit: (json['grossProfit'] as num).toDouble(),
      grossMargin: (json['grossMargin'] as num).toDouble(),
      operatingCost: (json['operatingCost'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
    );
  }
}

// 收支明细
class PaymentItem {
  final String id;
  final String type;  // income/expense
  final String category;
  final double amount;
  final String? relatedOrderNo;
  final String? remark;
  final DateTime paymentTime;

  PaymentItem({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.relatedOrderNo,
    this.remark,
    required this.paymentTime,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      relatedOrderNo: json['relatedOrderNo'],
      remark: json['remark'],
      paymentTime: DateTime.parse(json['paymentTime']),
    );
  }
}

// 应收应付明细
class ReceivableItem {
  final String id;
  final String type;  // receivable/payable
  final String customerOrSupplierName;
  final double amount;
  final double settledAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final int status;

  ReceivableItem({
    required this.id,
    required this.type,
    required this.customerOrSupplierName,
    required this.amount,
    required this.settledAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
  });

  factory ReceivableItem.fromJson(Map<String, dynamic> json) {
    return ReceivableItem(
      id: json['id'],
      type: json['type'],
      customerOrSupplierName: json['customerOrSupplierName'],
      amount: (json['amount'] as num).toDouble(),
      settledAmount: (json['settledAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
    );
  }

  String get statusName {
    switch (status) {
      case 0: return '未结清';
      case 1: return '已结清';
      case 2: return '已逾期';
      default: return '未知';
    }
  }
}
