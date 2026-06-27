// 职员模型
class Staff {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String departmentId;
  final String departmentName;
  final String position;
  final int status; // 0=禁用, 1=在职, 2=离职
  final List<String> roleIds;
  final DateTime? entryDate;
  final DateTime? leaveDate;
  final DateTime createTime;
  final DateTime updateTime;

  Staff({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    required this.departmentId,
    required this.departmentName,
    required this.position,
    this.status = 1,
    this.roleIds = const [],
    this.entryDate,
    this.leaveDate,
    required this.createTime,
    required this.updateTime,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avatar'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      position: json['position'],
      status: json['status'] ?? 1,
      roleIds: List<String>.from(json['roleIds'] ?? []),
      entryDate: json['entryDate'] != null ? DateTime.parse(json['entryDate']) : null,
      leaveDate: json['leaveDate'] != null ? DateTime.parse(json['leaveDate']) : null,
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'position': position,
      'status': status,
      'roleIds': roleIds,
      'entryDate': entryDate?.toIso8601String(),
      'leaveDate': leaveDate?.toIso8601String(),
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  String get statusName {
    switch (status) {
      case 0: return '禁用';
      case 1: return '在职';
      case 2: return '离职';
      default: return '未知';
    }
  }
}

// 部门模型
class Department {
  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final int sort;
  final DateTime createTime;

  Department({
    required this.id,
    required this.name,
    this.parentId,
    this.description,
    this.sort = 0,
    required this.createTime,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
      description: json['description'],
      sort: json['sort'] ?? 0,
      createTime: DateTime.parse(json['createTime']),
    );
  }
}

// 角色模型
class Role {
  final String id;
  final String name;
  final String? description;
  final List<String> permissions;
  final int status;
  final DateTime createTime;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
    this.status = 1,
    required this.createTime,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      permissions: List<String>.from(json['permissions'] ?? []),
      status: json['status'] ?? 1,
      createTime: DateTime.parse(json['createTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'status': status,
      'createTime': createTime.toIso8601String(),
    };
  }
}

// 预定义角色
class PredefinedRoles {
  static const String admin = 'admin';           // 超级管理员
  static const String owner = 'owner';           // 老板/店主
  static const String manager = 'manager';       // 经理
  static const String salesperson = 'salesperson'; // 销售员
  static const String purchaser = 'purchaser';   // 采购员
  static const String warehouse = 'warehouse';   // 库管
  static const String accountant = 'accountant'; // 财务
  static const String cashier = 'cashier';       // 收银员
  static const String viewer = 'viewer';         // 仅查看

  static Map<String, String> get names => {
    admin: '超级管理员',
    owner: '老板',
    manager: '经理',
    salesperson: '销售员',
    purchaser: '采购员',
    warehouse: '库管',
    accountant: '财务',
    cashier: '收银员',
    viewer: '仅查看',
  };
}
