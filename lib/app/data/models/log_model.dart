// 操作日志模型
class OperationLog {
  final String id;
  final String operatorId;
  final String operatorName;
  final String module;
  final String action;
  final String? targetId;
  final String? targetType;
  final String? description;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createTime;

  OperationLog({
    required this.id,
    required this.operatorId,
    required this.operatorName,
    required this.module,
    required this.action,
    this.targetId,
    this.targetType,
    this.description,
    this.ipAddress,
    this.userAgent,
    required this.createTime,
  });

  factory OperationLog.fromJson(Map<String, dynamic> json) {
    return OperationLog(
      id: json['id'],
      operatorId: json['operatorId'],
      operatorName: json['operatorName'],
      module: json['module'],
      action: json['action'],
      targetId: json['targetId'],
      targetType: json['targetType'],
      description: json['description'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      createTime: DateTime.parse(json['createTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'module': module,
      'action': action,
      'targetId': targetId,
      'targetType': targetType,
      'description': description,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'createTime': createTime.toIso8601String(),
    };
  }

  String get moduleName {
    final names = {
      'sale': '销售',
      'purchase': '采购',
      'inventory': '库存',
      'product': '商品',
      'customer': '客户',
      'supplier': '供应商',
      'finance': '财务',
      'staff': '职员',
      'system': '系统',
    };
    return names[module] ?? module;
  }
}

// 日志类型定义
class LogAction {
  static const String create = 'CREATE';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';
  static const String view = 'VIEW';
  static const String export = 'EXPORT';
  static const String import_ = 'IMPORT';
  static const String login = 'LOGIN';
  static const String logout = 'LOGOUT';
  static const String approve = 'APPROVE';
  static const String reject = 'REJECT';
  static const String transfer = 'TRANSFER';
  static const String check = 'CHECK';

  static String getName(String action) {
    final names = {
      create: '新增',
      update: '修改',
      delete: '删除',
      view: '查看',
      export: '导出',
      import_: '导入',
      login: '登录',
      logout: '登出',
      approve: '审核通过',
      reject: '驳回',
      transfer: '调拨',
      check: '盘点',
    };
    return names[action] ?? action;
  }
}
