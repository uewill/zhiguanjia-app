// 权限模型
class Permission {
  final String code;
  final String name;
  final String module;
  final String? parentCode;
  final int type; // 1=菜单, 2=按钮, 3=接口
  final String? icon;
  final String? route;
  final int sort;

  Permission({
    required this.code,
    required this.name,
    required this.module,
    this.parentCode,
    this.type = 1,
    this.icon,
    this.route,
    this.sort = 0,
  });

  // 所有预定义权限
  static List<Permission> get allPermissions => [
    // 销售管理
    Permission(code: 'sale', name: '销售管理', module: 'sale', type: 1, icon: 'shop', sort: 10),
    Permission(code: 'sale:view', name: '查看销售订单', module: 'sale', parentCode: 'sale', type: 3),
    Permission(code: 'sale:create', name: '新建销售订单', module: 'sale', parentCode: 'sale', type: 2),
    Permission(code: 'sale:edit', name: '编辑销售订单', module: 'sale', parentCode: 'sale', type: 2),
    Permission(code: 'sale:delete', name: '删除销售订单', module: 'sale', parentCode: 'sale', type: 2),
    Permission(code: 'sale:approve', name: '审核销售订单', module: 'sale', parentCode: 'sale', type: 2),
    Permission(code: 'sale:export', name: '导出销售数据', module: 'sale', parentCode: 'sale', type: 2),

    // 采购管理
    Permission(code: 'purchase', name: '采购管理', module: 'purchase', type: 1, icon: 'cart', sort: 20),
    Permission(code: 'purchase:view', name: '查看采购订单', module: 'purchase', parentCode: 'purchase', type: 3),
    Permission(code: 'purchase:create', name: '新建采购订单', module: 'purchase', parentCode: 'purchase', type: 2),
    Permission(code: 'purchase:edit', name: '编辑采购订单', module: 'purchase', parentCode: 'purchase', type: 2),
    Permission(code: 'purchase:delete', name: '删除采购订单', module: 'purchase', parentCode: 'purchase', type: 2),
    Permission(code: 'purchase:approve', name: '审核采购订单', module: 'purchase', parentCode: 'purchase', type: 2),

    // 库存管理
    Permission(code: 'inventory', name: '库存管理', module: 'inventory', type: 1, icon: 'warehouse', sort: 30),
    Permission(code: 'inventory:view', name: '查看库存', module: 'inventory', parentCode: 'inventory', type: 3),
    Permission(code: 'inventory:transfer', name: '库存调拨', module: 'inventory', parentCode: 'inventory', type: 2),
    Permission(code: 'inventory:check', name: '库存盘点', module: 'inventory', parentCode: 'inventory', type: 2),
    Permission(code: 'inventory:adjust', name: '库存调整', module: 'inventory', parentCode: 'inventory', type: 2),
    Permission(code: 'inventory:warning', name: '库存预警设置', module: 'inventory', parentCode: 'inventory', type: 2),

    // 商品管理
    Permission(code: 'product', name: '商品管理', module: 'product', type: 1, icon: 'package', sort: 40),
    Permission(code: 'product:view', name: '查看商品', module: 'product', parentCode: 'product', type: 3),
    Permission(code: 'product:create', name: '新增商品', module: 'product', parentCode: 'product', type: 2),
    Permission(code: 'product:edit', name: '编辑商品', module: 'product', parentCode: 'product', type: 2),
    Permission(code: 'product:delete', name: '删除商品', module: 'product', parentCode: 'product', type: 2),
    Permission(code: 'product:price', name: '修改价格', module: 'product', parentCode: 'product', type: 2),

    // 客户管理
    Permission(code: 'customer', name: '客户管理', module: 'customer', type: 1, icon: 'user', sort: 50),
    Permission(code: 'customer:view', name: '查看客户', module: 'customer', parentCode: 'customer', type: 3),
    Permission(code: 'customer:create', name: '新增客户', module: 'customer', parentCode: 'customer', type: 2),
    Permission(code: 'customer:edit', name: '编辑客户', module: 'customer', parentCode: 'customer', type: 2),
    Permission(code: 'customer:delete', name: '删除客户', module: 'customer', parentCode: 'customer', type: 2),

    // 供应商管理
    Permission(code: 'supplier', name: '供应商管理', module: 'supplier', type: 1, icon: 'truck', sort: 60),
    Permission(code: 'supplier:view', name: '查看供应商', module: 'supplier', parentCode: 'supplier', type: 3),
    Permission(code: 'supplier:create', name: '新增供应商', module: 'supplier', parentCode: 'supplier', type: 2),
    Permission(code: 'supplier:edit', name: '编辑供应商', module: 'supplier', parentCode: 'supplier', type: 2),

    // 财务管理
    Permission(code: 'finance', name: '财务管理', module: 'finance', type: 1, icon: 'money', sort: 70),
    Permission(code: 'finance:view', name: '查看财务', module: 'finance', parentCode: 'finance', type: 3),
    Permission(code: 'finance:receipt', name: '收款', module: 'finance', parentCode: 'finance', type: 2),
    Permission(code: 'finance:payment', name: '付款', module: 'finance', parentCode: 'finance', type: 2),
    Permission(code: 'finance:report', name: '财务报表', module: 'finance', parentCode: 'finance', type: 2),

    // 职员管理（仅管理员）
    Permission(code: 'staff', name: '职员管理', module: 'system', type: 1, icon: 'team', sort: 80),
    Permission(code: 'staff:view', name: '查看职员', module: 'system', parentCode: 'staff', type: 3),
    Permission(code: 'staff:create', name: '新增职员', module: 'system', parentCode: 'staff', type: 2),
    Permission(code: 'staff:edit', name: '编辑职员', module: 'system', parentCode: 'staff', type: 2),
    Permission(code: 'staff:delete', name: '删除职员', module: 'system', parentCode: 'staff', type: 2),
    Permission(code: 'staff:role', name: '分配角色', module: 'system', parentCode: 'staff', type: 2),

    // 系统设置
    Permission(code: 'setting', name: '系统设置', module: 'system', type: 1, icon: 'setting', sort: 90),
    Permission(code: 'setting:basic', name: '基本设置', module: 'system', parentCode: 'setting', type: 2),
    Permission(code: 'setting:backup', name: '数据备份', module: 'system', parentCode: 'setting', type: 2),
    Permission(code: 'setting:log', name: '操作日志', module: 'system', parentCode: 'setting', type: 2),
  ];

  // 角色默认权限配置
  static Map<String, List<String>> get roleDefaultPermissions => {
    'admin': allPermissions.map((p) => p.code).toList(),
    'owner': [
      'sale', 'sale:view', 'sale:create', 'sale:edit', 'sale:delete', 'sale:approve', 'sale:export',
      'purchase', 'purchase:view', 'purchase:create', 'purchase:edit', 'purchase:delete', 'purchase:approve',
      'inventory', 'inventory:view', 'inventory:transfer', 'inventory:check', 'inventory:adjust', 'inventory:warning',
      'product', 'product:view', 'product:create', 'product:edit', 'product:delete', 'product:price',
      'customer', 'customer:view', 'customer:create', 'customer:edit', 'customer:delete',
      'supplier', 'supplier:view', 'supplier:create', 'supplier:edit',
      'finance', 'finance:view', 'finance:receipt', 'finance:payment', 'finance:report',
      'staff', 'staff:view', 'staff:create', 'staff:edit', 'staff:delete', 'staff:role',
      'setting', 'setting:basic', 'setting:backup', 'setting:log',
    ],
    'manager': [
      'sale', 'sale:view', 'sale:create', 'sale:edit', 'sale:approve',
      'purchase', 'purchase:view', 'purchase:create', 'purchase:edit', 'purchase:approve',
      'inventory', 'inventory:view', 'inventory:transfer', 'inventory:check', 'inventory:adjust',
      'product', 'product:view', 'product:create', 'product:edit',
      'customer', 'customer:view', 'customer:create', 'customer:edit',
      'supplier', 'supplier:view', 'supplier:create', 'supplier:edit',
      'finance', 'finance:view', 'finance:receipt', 'finance:payment',
    ],
    'salesperson': [
      'sale', 'sale:view', 'sale:create', 'sale:edit',
      'customer', 'customer:view', 'customer:create',
      'product', 'product:view',
    ],
    'purchaser': [
      'purchase', 'purchase:view', 'purchase:create', 'purchase:edit',
      'supplier', 'supplier:view', 'supplier:create',
      'product', 'product:view',
    ],
    'warehouse': [
      'inventory', 'inventory:view', 'inventory:transfer', 'inventory:check',
      'purchase', 'purchase:view',
      'sale', 'sale:view',
      'product', 'product:view',
    ],
    'accountant': [
      'finance', 'finance:view', 'finance:receipt', 'finance:payment', 'finance:report',
      'sale', 'sale:view',
      'purchase', 'purchase:view',
    ],
    'cashier': [
      'finance', 'finance:view', 'finance:receipt', 'finance:payment',
      'sale', 'sale:view', 'sale:create',
    ],
    'viewer': [
      'sale', 'sale:view',
      'purchase', 'purchase:view',
      'inventory', 'inventory:view',
      'product', 'product:view',
    ],
  };
}

// 权限工具类
class PermissionUtils {
  // 检查是否有权限
  static bool hasPermission(List<String> userPermissions, String requiredPermission) {
    // 管理员拥有所有权限
    if (userPermissions.contains('admin')) return true;
    // 检查具体权限
    return userPermissions.contains(requiredPermission);
  }

  // 检查是否有任意一个权限
  static bool hasAnyPermission(List<String> userPermissions, List<String> requiredPermissions) {
    if (userPermissions.contains('admin')) return true;
    return requiredPermissions.any((p) => userPermissions.contains(p));
  }

  // 检查是否有所有权限
  static bool hasAllPermissions(List<String> userPermissions, List<String> requiredPermissions) {
    if (userPermissions.contains('admin')) return true;
    return requiredPermissions.every((p) => userPermissions.contains(p));
  }
}
