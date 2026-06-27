# 智管家 - 打印服务后端API设计

## 概述

打印服务采用后端生成PDF，前端下载后打印的架构设计。

## 技术选型

- **PDF生成库**: Puppeteer + Chrome / Playwright
- **模板引擎**: HTML + CSS (Handlebars/EJS)
- **存储**: MinIO / S3 (临时PDF存储)
- **队列**: Redis + Bull (异步处理)

## API接口

### 1. 模版管理

#### 获取模版列表
```http
GET /api/print/templates
Query: type=receipt|delivery|invoice
```

#### 保存模版
```http
POST /api/print/templates
Content-Type: application/json

{
  "id": "template_001",
  "name": "默认小票",
  "type": "receipt",
  "description": "80mm热敏纸小票",
  "paperSize": {
    "name": "80mm",
    "width": 80,
    "height": 0
  },
  "elements": [...],
  "globalStyle": {...}
}
```

### 2. PDF生成

#### 创建打印任务
```http
POST /api/print/jobs
Content-Type: application/json

{
  "templateId": "template_001",
  "documentType": "order",
  "documentId": "ORDER20240101001",
  "data": {
    "shopName": "测试店铺",
    "orderNo": "ORDER20240101001",
    "orderTime": "2024-01-01 12:00:00",
    "items": [
      {"name": "商品A", "quantity": 2, "price": 10.00, "amount": 20.00}
    ],
    "totalQuantity": 2,
    "totalAmount": 20.00,
    "paymentMethod": "微信支付"
  }
}
```

**Response:**
```json
{
  "code": 200,
  "data": {
    "jobId": "job_123456",
    "status": "pending",
    "estimatedTime": 3000
  }
}
```

#### 查询打印任务状态
```http
GET /api/print/jobs/{jobId}
```

**Response:**
```json
{
  "code": 200,
  "data": {
    "jobId": "job_123456",
    "status": "completed",
    "pdfUrl": "https://storage.example.com/print/job_123456.pdf",
    "expireTime": "2024-01-08T12:00:00Z"
  }
}
```

#### 预览PDF（同步）
```http
POST /api/print/preview
Content-Type: application/json

{
  "templateId": "template_001",
  "data": {...}
}
```

**Response:**
```json
{
  "code": 200,
  "data": {
    "pdfUrl": "https://storage.example.com/print/preview_xxx.pdf",
    "expireTime": "2024-01-01T13:00:00Z"
  }
}
```

### 3. 直接打印（WebSocket）

```javascript
// WebSocket连接
ws://api.example.com/ws/print

// 发送打印命令
{
  "type": "print",
  "printerId": "printer_001",
  "jobId": "job_123456"
}

// 打印状态回调
{
  "type": "status",
  "jobId": "job_123456",
  "status": "printing|completed|failed",
  "message": "..."
}
```

## 模版HTML结构

### 小票模版 (Receipt)

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    @page {
      size: 80mm auto;
      margin: 0;
    }
    body {
      width: 80mm;
      font-family: "Microsoft YaHei", sans-serif;
      font-size: 12pt;
      margin: 0;
      padding: 5mm;
    }
    .center { text-align: center; }
    .bold { font-weight: bold; }
    .large { font-size: 16pt; }
    .line {
      border-top: 1px dashed #000;
      margin: 5mm 0;
    }
    table { width: 100%; border-collapse: collapse; }
    td { padding: 2mm 0; }
    .right { text-align: right; }
  </style>
</head>
<body>
  <div class="center bold large">{{shopName}}</div>
  <div class="line"></div>
  <div>订单号: {{orderNo}}</div>
  <div>时间: {{orderTime}}</div>
  <div class="line"></div>
  <table>
    <tr class="bold">
      <td>商品</td>
      <td>数量</td>
      <td class="right">金额</td>
    </tr>
    {{#each items}}
    <tr>
      <td>{{name}}</td>
      <td>{{quantity}}</td>
      <td class="right">{{amount}}</td>
    </tr>
    {{/each}}
  </table>
  <div class="line"></div>
  <div class="bold right">合计: ¥{{totalAmount}}</div>
  <div>支付方式: {{paymentMethod}}</div>
  <div class="line"></div>
  <div class="center">感谢惠顾，欢迎下次光临!</div>
</body>
</html>
```

### 发货单模版 (Delivery)

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    @page {
      size: A5;
      margin: 15mm;
    }
    body {
      font-family: "Microsoft YaHei", sans-serif;
      font-size: 11pt;
    }
    .title {
      text-align: center;
      font-size: 20pt;
      font-weight: bold;
      margin-bottom: 10mm;
    }
    .section {
      margin-bottom: 8mm;
    }
    .section-title {
      font-weight: bold;
      border-bottom: 1px solid #000;
      padding-bottom: 2mm;
      margin-bottom: 3mm;
    }
    table {
      width: 100%;
      border-collapse: collapse;
    }
    th, td {
      border: 1px solid #000;
      padding: 3mm;
      text-align: left;
    }
    th {
      background-color: #f0f0f0;
    }
    .sign-area {
      margin-top: 15mm;
      display: flex;
      justify-content: space-between;
    }
  </style>
</head>
<body>
  <div class="title">发 货 单</div>

  <div class="section">
    <div class="section-title">订单信息</div>
    <div>订单号: {{orderNo}}</div>
    <div>下单时间: {{orderTime}}</div>
  </div>

  <div class="section">
    <div class="section-title">收货人信息</div>
    <div>姓名: {{customerName}}</div>
    <div>电话: {{customerPhone}}</div>
    <div>地址: {{customerAddress}}</div>
  </div>

  <div class="section">
    <div class="section-title">发货明细</div>
    <table>
      <tr>
        <th>序号</th>
        <th>商品名称</th>
        <th>规格</th>
        <th>数量</th>
      </tr>
      {{#each items}}
      <tr>
        <td>{{@index}}</td>
        <td>{{name}}</td>
        <td>{{spec}}</td>
        <td>{{quantity}}</td>
      </tr>
      {{/each}}
    </table>
  </div>

  <div class="sign-area">
    <div>收货人签字: _______________</div>
    <div>日期: _______________</div>
  </div>
</body>
</html>
```

## 数据库模型

```sql
-- 打印模版表
CREATE TABLE print_templates (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    type VARCHAR(32) NOT NULL, -- receipt, delivery, invoice
    description TEXT,
    paper_size JSON NOT NULL, -- {name, width, height}
    elements JSON NOT NULL, -- 元素配置数组
    global_style JSON, -- 全局样式
    html_template TEXT, -- 预编译的HTML模板
    is_default BOOLEAN DEFAULT FALSE,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type)
);

-- 打印任务表
CREATE TABLE print_jobs (
    id VARCHAR(64) PRIMARY KEY,
    template_id VARCHAR(64) NOT NULL,
    document_type VARCHAR(32) NOT NULL,
    document_id VARCHAR(64) NOT NULL,
    data JSON NOT NULL, -- 打印数据
    status VARCHAR(32) DEFAULT 'pending', -- pending, processing, completed, failed
    pdf_url VARCHAR(512),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    INDEX idx_status (status),
    INDEX idx_document (document_type, document_id)
);

-- 打印机配置表
CREATE TABLE printers (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    type VARCHAR(32) NOT NULL, -- bluetooth, network, usb
    connection_config JSON NOT NULL, -- {连接参数}
    paper_size VARCHAR(32),
    is_default BOOLEAN DEFAULT FALSE,
    is_online BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 流程图

```
前端请求打印
    ↓
创建PrintJob (状态: pending)
    ↓
入队 (Redis + Bull)
    ↓
工作进程处理
  - 获取模版HTML
  - 替换数据 (Handlebars)
  - Puppeteer生成PDF
    ↓
上传PDF到MinIO/S3
    ↓
更新Job状态 (状态: completed)
    ↓
前端轮询获取pdfUrl
    ↓
下载PDF并打印
```

## 安全考虑

1. **PDF访问授权**: 使用预签名URL，有效期30分钟
2. **模版验证**: HTML模版需要过滤危险标签
3. **数据隐私**: 打印数据不落地存储，仅在内存中处理
4. **访问控制**: 打印API需要授权，验证用户对订单的访问权限
