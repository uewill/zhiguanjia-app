# 智掌柜 - 打印功能使用指南

## 支持的打印机类型

| 打印机类型 | 通信方式 | 指令集 | 适用场景 |
|---------|---------|--------|---------|
| 蓝牙热敏打印机 | 蓝牙 | ESC/POS | 小票打印 |
| TSC 标签打印机 | 蓝牙 | TSPL | 条码标签打印 |

---

## 一、小票打印

### 从订单打印小票

1. 进入订单详情页
2. 点击底部的 **"打印小票"** 按钮
3. 选择打印机模板（如果需要）
4. 连接蓝牙打印机
5. 发送打印指令

### 代码示例

```dart
// 生成小票 ESC 指令
final commands = PrinterCommandService.generateReceiptEsc(
  shopName: '智掌柜店铺',
  shopAddress: '市中区中心路123号',
  orderNo: 'SO202412310001',
  orderTime: '2024-12-31 14:30:00',
  cashier: '张三',
  items: [
    {'name': '可乐', 'quantity': 2, 'price': 3.50, 'amount': 7.00},
    {'name': '雪碧', 'quantity': 1, 'price': 4.00, 'amount': 4.00},
  ],
  totalAmount: 11.00,
  paymentMethod: '微信支付',
);

// 通过蓝牙发送
await bluetoothConnection.output.add(Uint8List.fromList(commands));
```

---

## 二、条码打印

### 从商品管理打印条码

1. 进入商品列表页
2. 点击商品卡片右上角的 **📹 打印** 图标
3. 选择条码模板
4. 设置打印份数
5. 点击开始打印

### 从订单打印条码

1. 进入订单详情页
2. 点击底部的 **"打印条码"** 按钮
3. 系统自动提取订单中有条码的商品
4. 选择模板并打印

### 路由使用

```dart
// 从商品页面进入
Get.toNamed('/barcode/print', arguments: {
  'product': {
    'id': 1,
    'name': '可乐',
    'barcode': '6901234567890',
    'salePrice': 3.50,
  },
});

// 从订单页面进入
Get.toNamed('/barcode/print', arguments: {
  'products': [
    {'name': '可乐', 'barcode': '6901234567890', 'salePrice': 3.50},
    {'name': '雪碧', 'barcode': '6909876543210', 'salePrice': 4.00},
  ],
});
```

---

## 三、条码模板管理

### 进入模板管理

- 路径：`设置` -> `打印设置` -> `条码模板`
- 或直接访问 `/barcode/templates`

### 模板类型

| 模板类型 | 说明 | 适用标签 |
|---------|------|---------|
| product_barcode | 商品条码标签 | 40x30mm |
| shelf_label | 货架标签 | 60x40mm |
| price_tag | 价格标签 | 30x20mm |

### 模板设计器使用

1. 选择标签尺寸
2. 添加元素（文本、条码、二维码、价格）
3. 拖拽调整位置
4. 修改样式（字体、大小、粗细）
5. 保存模板

### 可用元素

| 元素类型 | 说明 | 数据源 |
|---------|------|--------|
| 商品名称 | 显示商品名称 | product.name |
| 条形码 | CODE128/EAN-13 条码 | product.barcode |
| 二维码 | QR Code | product.barcode |
| 售价 | 金额显示 | product.salePrice |
| 规格 | 商品规格 | product.spec |
| 静态文本 | 自定义文字 | 手动输入 |

---

## 四、蓝牙打印机连接

### 连接流程

1. 确保打印机已开机并进入配对模式
2. 在打印页面点击 **"连接"** 按钮
3. 系统自动扫描周边的蓝牙设备
4. 选择目标打印机并连接

### 自动重连

- 系统会自动记忆上次连接的打印机
- 下次打开应用时自动尝试重连

---

## 五、TSPL 指令示例

### 单个商品条码标签

```tspl
SIZE 40 mm,30 mm
GAP 2 mm
DIRECTION 1
CLS
TEXT 10,10,"TSS24.BF2",0,1,1,"可乐"
BARCODE 10,40,"128",50,1,0,2,4,"6901234567890"
TEXT 200,100,"TSS24.BF2",0,2,2,"¥3.50"
PRINT 1
END
```

### 多商品标签页

```tspl
SIZE 80 mm,150 mm
GAP 2 mm
DIRECTION 0
CLS

// 第一个商品 (0,0)
TEXT 10,10,"TSS16.BF2",0,1,1,"可乐"
BARCODE 10,35,"128",35,1,0,2,4,"6901234567890"
TEXT 160,90,"TSS20.BF2",0,1,1,"¥3.5"

// 第二个商品 (40mm,0)
TEXT 330,10,"TSS16.BF2",0,1,1,"雪碧"
BARCODE 330,35,"128",35,1,0,2,4,"6909876543210"
TEXT 480,90,"TSS20.BF2",0,1,1,"¥4.0"

PRINT 1
END
```

---

## 六、ESC/POS 指令示例

### 小票打印

```hex
1B 40              // 初始化
1B 61 01           // 居中
1D 21 11           // 双倍字体
E5 BA 97 E9 93 BA E5 90 8D 0A  // "店铺名"(UTF-8) + 换行
1B 61 00           // 左对齐
1D 21 00           // 普通字体
E5 95 86 E5 93 81 3A 20 XX XX 0A  // 商品列表
1B 61 02           // 右对齐
E5 90 88 E8 AE A1 3A 20 XX XX 0A  // 合计
1D 56 01           // 切纸
```

---

## 七、相关文件说明

| 文件 | 说明 |
|------|------|
| `lib/app/services/printer_command_service.dart` | TSPL/ESC 指令生成 |
| `lib/app/services/barcode_print_service.dart` | 蓝牙打印控制 |
| `lib/app/utils/printer_commands.dart` | 指令工具类 |
| `lib/app/data/models/barcode_template_model.dart` | 条码模板模型 |
| `lib/app/modules/barcode/views/barcode_print_view.dart` | 条码打印页面 |
| `lib/app/modules/barcode/views/barcode_template_editor_view.dart` | 模板设计器 |

---

## 八、常见问题

### 打印机连接失败
- 确保打印机已开机
- 确保打印机进入蓝牙配对模式
- 检查设备是否已配对过

### 打印内容错位
- 检查模板尺寸设置
- 调整元素坐标
- 确认打印机 DPI 设置

### 条码无法扫描
- 确认条码数据格式正确
- 调整条码高度和宽度
- 检查打印清晰度
