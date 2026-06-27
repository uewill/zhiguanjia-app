# 智掌柜核心框架

## 概述

本框架基于设计模式实现，提供单据类和资料类页面的统一抽象。

## 设计模式

### 1. 模板方法模式 (Template Method Pattern)

定义算法的骨架，将某些步骤延迟到子类实现。

- `BillCreateController` - 单据创建控制器模板
- `DataController` - 资料管理控制器模板
- `DataFormController` - 资料表单控制器模板
- `BillCreatePage` - 单据创建页面模板
- `DataListView` - 资料列表页面模板
- `DataFormView` - 资料表单页面模板

### 2. 策略模式 (Strategy Pattern)

封装不同的算法或行为，使它们可以互相替换。

- `BillType` - 单据类型配置（采购/销售/调拨等）
- `DataPageConfig` - 资料页面配置（客户/供应商/仓库/商品等）

### 3. 组合模式 (Composition)

将对象组合成树形结构以表示"整体-部分"的层次结构。

- 复用组件：`PartnerSelector`、`WarehouseSelector`、`ProductSelector`、`ItemList`、`RemarkCard`、`BillBottomBar`

## 目录结构

```
lib/app/core/
├── bill/              # 单据类抽象框架
│   ├── bill_type.dart        # 单据类型配置
│   ├── bill_base.dart        # 单据基类/明细基类
│   ├── bill_controller.dart  # 单据控制器模板
│   └── bill_create_page.dart # 单据创建页面模板
├── components/        # 可复用UI组件
│   ├── partner_selector.dart   # 往来单位选择器
│   ├── warehouse_selector.dart # 仓库选择器
│   ├── product_selector.dart   # 商品选择器
│   ├── item_list.dart          # 明细列表
│   ├── date_selector.dart      # 日期选择器
│   ├── remark_card.dart        # 备注输入卡片
│   └── bill_bottom_bar.dart    # 单据页面底部栏
├── data/              # 资料类抽象框架
│   ├── data_base.dart        # 资料项基类/配置
│   ├── data_controller.dart  # 资料控制器模板
│   ├── data_list_view.dart   # 资料列表页面模板
│   └── data_form_view.dart   # 资料表单页面模板
└── index.dart         # 统一导出
```

## 使用示例

### 单据类

```dart
// 1. 定义控制器
class PurchaseOrderController extends BillCreateController {
  @override
  BillType get billType => BillType.purchase;
  
  @override
  Future<List<Map<String, dynamic>>> loadPartners() async {
    // 加载供应商
  }
  
  // ... 其他必要实现的方法
}

// 2. 定义页面
class PurchaseOrderCreateView extends BillCreatePage<PurchaseOrderController> {
  // 可选：覆盖特定方法来定制页面
}
```

### 资料类

```dart
// 1. 定义数据模型
class CustomerModel implements DataItem {
  @override
  final int? id;
  @override
  final String name;
  // ...
}

// 2. 定义控制器
class CustomerController extends DataController<CustomerModel> {
  @override
  DataPageConfig get config => DataPageConfig.customer;
  
  @override
  CustomerModel fromJson(Map<String, dynamic> json) => 
    CustomerModel.fromJson(json);
}

// 3. 定义页面
class CustomerListView extends DataListView<CustomerModel> {
  // 可选：覆盖方法来定制显示
}
```

## 优势

1. **代码复用**: 95%以上的代码复用率，减少重复代码
2. **统一体验**: 所有页面保持一致的设计和交互
3. **易维护**: 修改模板即可影响所有相关页面
4. **易扩展**: 新增单据类型或资料类型只需实现少量方法
5. **类型安全**: 使用泛型保证编译期安全
