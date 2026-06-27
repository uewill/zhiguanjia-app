// 单据状态流转模型
class OrderStatus {
  static const int pending = 0;      // 待审核
  static const int approved = 1;     // 已审核
  static const int inProgress = 2;   // 执行中
  static const int completed = 3;    // 已完成
  static const int cancelled = 4;    // 已取消
  static const int rejected = 5;     // 已驳回

  static String getName(int status) {
    switch (status) {
      case pending: return '待审核';
      case approved: return '已审核';
      case inProgress: return '执行中';
      case completed: return '已完成';
      case cancelled: return '已取消';
      case rejected: return '已驳回';
      default: return '未知';
    }
  }

  static int getColor(int status) {
    switch (status) {
      case pending: return 0xFFFF9500;     // 橙色
      case approved: return 0xFF2FC27D;    // 绿色
      case inProgress: return 0xFF1890FF;  // 蓝色
      case completed: return 0xFF52C41A;   // 深绿
      case cancelled: return 0xFF999999;   // 灰色
      case rejected: return 0xFFFF4D4F;    // 红色
      default: return 0xFF999999;
    }
  }
}

// 状态流转规则
class StatusTransition {
  final int fromStatus;
  final int toStatus;
  final String actionName;      // 操作名称（如审核、驳回）
  final String? requiredRole;   // 需要的角色
  final bool requireReason;     // 是否需要填写原因

  StatusTransition({
    required this.fromStatus,
    required this.toStatus,
    required this.actionName,
    this.requiredRole,
    this.requireReason = false,
  });

  // 获取所有流转规则
  static List<StatusTransition> get allRules => [
    // 待审核 -> 已审核/已驳回/已取消
    StatusTransition(fromStatus: OrderStatus.pending, toStatus: OrderStatus.approved, actionName: '审核通过', requiredRole: 'manager'),
    StatusTransition(fromStatus: OrderStatus.pending, toStatus: OrderStatus.rejected, actionName: '驳回', requiredRole: 'manager', requireReason: true),
    StatusTransition(fromStatus: OrderStatus.pending, toStatus: OrderStatus.cancelled, actionName: '取消'),
    
    // 已审核 -> 执行中/已取消
    StatusTransition(fromStatus: OrderStatus.approved, toStatus: OrderStatus.inProgress, actionName: '开始执行'),
    StatusTransition(fromStatus: OrderStatus.approved, toStatus: OrderStatus.cancelled, actionName: '取消'),
    
    // 执行中 -> 已完成/已取消
    StatusTransition(fromStatus: OrderStatus.inProgress, toStatus: OrderStatus.completed, actionName: '完成'),
    StatusTransition(fromStatus: OrderStatus.inProgress, toStatus: OrderStatus.cancelled, actionName: '取消', requireReason: true),
  ];

  // 获取某状态可执行的操作
  static List<StatusTransition> getAvailableActions(int currentStatus) {
    return allRules.where((rule) => rule.fromStatus == currentStatus).toList();
  }
}

// 状态变更历史记录
class StatusHistory {
  final int id;
  final int orderId;
  final String orderType;       // sale, purchase, transfer
  final int fromStatus;
  final int toStatus;
  final String operatorId;      // 操作人ID
  final String operatorName;    // 操作人姓名
  final String? reason;         // 变更原因
  final DateTime createTime;

  StatusHistory({
    required this.id,
    required this.orderId,
    required this.orderType,
    required this.fromStatus,
    required this.toStatus,
    required this.operatorId,
    required this.operatorName,
    this.reason,
    required this.createTime,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'],
      orderId: json['orderId'],
      orderType: json['orderType'],
      fromStatus: json['fromStatus'],
      toStatus: json['toStatus'],
      operatorId: json['operatorId'],
      operatorName: json['operatorName'],
      reason: json['reason'],
      createTime: DateTime.parse(json['createTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'orderType': orderType,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'reason': reason,
      'createTime': createTime.toIso8601String(),
    };
  }
}
