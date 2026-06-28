# 智掌柜 APP - 可复用组件库

## 组件结构

```
lib/app/core/components/
├── index.dart                    # 统一导出
├── form_fields/                  # 表单字段组件
│   ├── index.dart
│   ├── bill_field_base.dart        # 基类
│   ├── bill_text_field.dart        # 文本输入
│   ├── bill_number_field.dart      # 数字输入
│   ├── bill_amount_field.dart      # 金额输入
│   ├── bill_date_field.dart        # 日期选择
│   ├── bill_selector_field.dart    # 选择器
│   ├── bill_search_selector_field.dart  # 搜索选择器
│   ├── bill_remark_field.dart      # 备注输入
│   └── bill_divider.dart           # 分割线
├── partner_selector.dart         # 往来单位选择器 UI
├── warehouse_selector.dart       # 仓库选择器 UI
├── product_selector.dart         # 商品选择器 UI
├── reusable_selectors.dart       # 底部选择器布局
├── product_info_card.dart        # 商品信息展示组件
├── item_list.dart                # 明细列表
├── date_selector.dart            # 日期选择器
├── remark_card.dart              # 备注输入
└── bill_bottom_bar.dart          # 底部操作栏
```

## 使用方法

### 1. 导入组件

```dart
import '../../../../app/core/components/index.dart';
```

### 2. 表单字段组件

```dart
// 表头字段
BillTextField(
  label: '单号',
  value: controller.billNo,
  hintText: '自动生成',
  readOnly: true,
)

BillSearchSelectorField(
  label: '客户',
  value: controller.selectedCustomer,
  hintText: '请选择客户',
  required: true,
  onTap: () => _showCustomerSelector(),
)

BillDateField(
  label: '业务日期',
  value: controller.billDate,
  required: true,
  onChanged: (date) => controller.setBillDate(date),
)

// 表尾字段
BillAmountField(
  label: '运费',
  value: controller.freight,
  hintText: '0.00',
  onChanged: (v) => controller.freight.value = v,
)

BillNumberField(
  label: '折扣率(%)',
  value: controller.discountRate,
  min: 0,
  max: 100,
  onChanged: (v) => controller.setDiscountRate(v),
)

BillRemarkField(
  label: '备注',
  value: controller.remark,
  onChanged: (v) => controller.remark.value = v,
)
```

### 3. 选择器组件

```dart
// 显示客户选择器
CustomerSelector.show(
  customers: _customerController.customers,
  isLoading: _customerController.isLoading.value,
  onRefresh: () => _customerController.loadCustomers(),
  onCreateNew: () => Get.toNamed('/customer/form'),
  onSelected: (customer) => controller.selectCustomer(customer),
);

// 显示供应商选择器
SupplierSelector.show(
  suppliers: _supplierController.suppliers,
  isLoading: _supplierController.isLoading.value,
  onRefresh: () => _supplierController.loadSuppliers(),
  onCreateNew: () => Get.toNamed('/supplier/form'),
  onSelected: (supplier) => controller.selectSupplier(supplier),
);

// 显示商品选择器
ProductSelector.show(
  products: _productController.products,
  isLoading: _productController.isLoading.value,
  priceGetter: (p) => '¥${p.salePrice?.toStringAsFixed(2) ?? '0.00'}',
  onRefresh: () => _productController.loadProducts(),
  onCreateNew: () => Get.toNamed('/product/form'),
  onSelected: (product) => _onProductSelected(product),
);
```

### 4. 商品信息展示

```dart
// 商品卡片
ProductInfoCard(
  name: '苹果 iPhone 15 Pro',
  code: 'IP15PRO-256',
  category: '手机',
  stock: 100,
  price: '¥8999.00',
  unit: '台',
  onTap: () => _selectProduct(),
)

// 明细项卡片（编辑模式）
BillItemCard(
  name: '苹果 iPhone 15 Pro',
  code: 'IP15PRO-256',
  unit: '台',
  quantity: 2,
  price: 8999.00,
  amount: 17998.00,
  onQuantityChanged: (v) => controller.updateQuantity(v),
  onPriceChanged: (v) => controller.updatePrice(v),
  onDelete: () => controller.removeItem(),
)

// 明细项列表（只读）
ProductListTile(
  name: '苹果 iPhone 15 Pro',
  code: 'IP15PRO-256',
  quantity: 2,
  unit: '台',
  price: 8999.00,
)
```

### 5. 明细列表

```dart
ItemList(
  label: '商品明细',
  items: controller.items,
  onAddItem: () => _showProductSelector(),
  onUpdateQuantity: (index, qty) => controller.updateItemQuantity(index, qty),
  onRemoveItem: (index) => controller.removeItem(index),
)
```

## 页面重构示例

采购单/销售单/调拨单页面已重构为使用模板方法模式，继承 `BillCreatePage`：

```dart
class PurchaseOrderCreateViewNew extends BillCreatePage<PurchaseOrderControllerNew> {
  const PurchaseOrderCreateViewNew({Key? key}) : super(key: key);

  @override
  State<BillCreatePage<PurchaseOrderControllerNew>> createState() => 
    _PurchaseOrderCreateViewNewState();
}

class _PurchaseOrderCreateViewNewState extends BillCreatePageState<PurchaseOrderControllerNew> {
  // 只需要实现必要的方法
  @override
  void _showPartnerSelector() {
    SupplierSelector.show(...);
  }

  @override
  void _showWarehouseSelector({bool isFrom = true}) {
    WarehouseSelector.show(...);
  }

  @override
  void _showProductSelector() {
    ProductSelector.show(...);
  }
}
```

## 优化效果

- 代码量减少约60%
- 所有选择器逻辑统一封装
- 商品展示样式一致
- 表单字段可在表头/表尾复用
