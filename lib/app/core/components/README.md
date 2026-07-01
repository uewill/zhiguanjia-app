# 智掌柜单据组件库

统一的 Flutter 单据组件库，支持表头、表尾、商品选择、商品展示等常用场景。

## 快速开始

```dart
import 'package:zhiguanjia/app/core/components/index.dart';
```

## 组件概览

### 1. 表头组件 (BillHeader)

统一的单据表头输入组件，支持多种字段类型：

```dart
BillHeader(
  fields: [
    BillHeaderField(
      key: 'billNo',
      label: '单号',
      type: BillHeaderFieldType.text,
      value: 'CG20240001',
      onChanged: (v) => controller.billNo.value = v,
    ),
    BillHeaderField(
      key: 'billDate',
      label: '日期',
      type: BillHeaderFieldType.date,
      value: DateTime.now(),
      onChanged: (v) => controller.billDate.value = v,
    ),
    BillHeaderField(
      key: 'warehouse',
      label: '入库仓库',
      type: BillHeaderFieldType.warehouse,
      icon: Icons.warehouse,
      iconColor: Colors.blue,
      value: controller.selectedWarehouse.value,
      onTap: () => _selectWarehouse(),
    ),
    BillHeaderField(
      key: 'supplier',
      label: '供应商',
      type: BillHeaderFieldType.partner,
      icon: Icons.business,
      iconColor: Colors.orange,
      value: controller.selectedSupplier.value,
      onTap: () => _selectSupplier(),
    ),
    BillHeaderField(
      key: 'remark',
      label: '备注',
      type: BillHeaderFieldType.remark,
      value: controller.remark.value,
      onChanged: (v) => controller.remark.value = v,
    ),
  ],
)
```

### 2. 表尾组件 (BillFooter)

统一的单据表尾金额组件：

```dart
// 简化版
SimpleBillFooter(
  totalQuantity: 10,
  totalAmount: 1000.00,
  submitText: '保存',
  onSubmit: () => _save(),
)

// 采购单/销售单版（带折扣、实付）
OrderBillFooter(
  totalQuantity: 10,
  totalAmount: 1000.00,
  discountAmount: 50.00,
  paidAmount: 500.00,
  onDiscountChanged: (v) => controller.discount.value = v,
  onPaidChanged: (v) => controller.paidAmount.value = v,
  submitText: '保存采购单',
  onSubmit: () => _save(),
)

// 完全自定义版
BillFooter(
  fields: [
    BillFooterField(
      key: 'total',
      label: '合计',
      type: BillFooterFieldType.amount,
      value: 1000.00,
      isBold: true,
    ),
    BillFooterField(
      key: 'discount',
      label: '折扣',
      type: BillFooterFieldType.discount,
      value: 50.00,
      onChanged: (v) => controller.discount.value = v,
    ),
    BillFooterField(
      key: 'payable',
      label: '应付',
      type: BillFooterFieldType.payable,
      value: 950.00,
      isBold: true,
    ),
  ],
  submitText: '保存',
  onSubmit: () => _save(),
)
```

### 3. 商品选择器 (ProductPicker)

统一的商品选择组件，支持单选/多选、搜索、批量确认：

```dart
// 显示选择器
ProductPicker.show(
  products: productList,
  multiSelect: true,  // 是否多选
  showStock: true,    // 是否显示库存
  allowPriceEdit: true, // 是否允许编辑价格
  onConfirm: (selectedProducts) {
    // 处理选中的商品列表
    for (var item in selectedProducts) {
      print('${item.product.name} x${item.quantity} = ¥${item.amount}');
    }
  },
);

// 单选模式
ProductPicker.show(
  products: productList,
  multiSelect: false,
  onSingleSelect: (product, quantity, price) {
    // 立即处理单个商品选择
    controller.addItem(product, quantity, price);
  },
);
```

### 4. 商品展示组件 (ProductDisplay)

多种模式的商品展示：

```dart
// 紧凑模式 - 列表项
ProductDisplay(
  product: product,
  mode: ProductDisplayMode.compact,
  quantity: 5,
  price: 100.00,
  onDelete: () => _remove(),
)

// 标准模式 - 卡片
ProductDisplay(
  product: product,
  mode: ProductDisplayMode.normal,
  onTap: () => _viewDetail(),
)

// 详细模式 - 带库存价格
ProductDisplay(
  product: product,
  mode: ProductDisplayMode.detailed,
)

// 单据明细模式 - 可编辑数量单价
ProductDisplay(
  product: product,
  mode: ProductDisplayMode.billItem,
  quantity: 5,
  price: 100.00,
  onQuantityChanged: (v) => controller.updateQuantity(v),
  onPriceChanged: (v) => controller.updatePrice(v),
  onDelete: () => _remove(),
)
```

### 5. 商品列表/网格

```dart
// 列表展示
ProductList(
  products: productList,
  mode: ProductDisplayMode.compact,
  onProductTap: (p) => _onTap(p),
)

// 网格展示
ProductGrid(
  products: productList,
  crossAxisCount: 2,
  onProductTap: (p) => _onTap(p),
)
```

## 数据模型

### SelectedProduct

```dart
class SelectedProduct {
  final ProductModel product;
  double quantity;
  double price;
  double get amount => quantity * price;
}
```

## 最佳实践

### 1. 表头表尾应该合并吗？

表头和表尾通常不建议合并，因为：
- 表头在页面顶部，表尾在页面底部
- 表头主要是输入字段，表尾主要是金额汇总
- 表尾通常包含提交按钮，表头不需要

### 2. 组件选型建议

| 场景 | 推荐组件 |
|------|---------|
| 采购单/销售单创建页 | BillHeader + ProductPicker + BillFooter |
| 入库单/出库单创建页 | BillHeader + ProductPicker + SimpleBillFooter |
| 商品列表页 | ProductList |
| 商品选择弹窗 | ProductPicker |
| 单据明细展示 | ProductDisplay(mode: billItem) |

### 3. 避免重复

所有单据页面都应该使用这些统一组件，避免重复实现相似功能的组件。
