# 智掌柜 - 并行开发计划

**制定时间:** 2026-06-27  
**预计完成:** 2026-06-30 (3天)  
**开发模式:** 5个并行线程

---

## 📝 任务列表

### P0 - 必备核心功能

| 任务 | 优先级 | 预计工时 | 负责人 | 状态 |
|------|--------|---------|--------|------|
| **1. 单据状态流转** | P0 | 6h | Thread-A | 🔧 进行中 |
| **2. 多职员管理** | P0 | 8h | Thread-B | ⏳ 待开始 |
| **3. 职员权限管理** | P0 | 8h | Thread-C | ⏳ 待开始 |
| **4. 库存预警系统** | P0 | 4h | Thread-D | ⏳ 待开始 |
| **5. 财务报表** | P0 | 6h | Thread-E | ⏳ 待开始 |

### P1 - 重要增强功能

| 任务 | 优先级 | 预计工时 | 负责人 | 状态 |
|------|--------|---------|--------|------|
| **6. 单据打印** | P1 | 4h | Thread-A | ⏳ 待开始 |
| **7. 数据备份** | P1 | 4h | Thread-B | ⏳ 待开始 |
| **8. 来往账管理** | P1 | 4h | Thread-C | ⏳ 待开始 |
| **9. 操作日志** | P1 | 3h | Thread-D | ⏳ 待开始 |

### P2 - 优化功能

| 任务 | 优先级 | 预计工时 | 说明 |
|------|--------|---------|------|
| 多单位/多规格 | P2 | 8h | 商品SKU管理 |
| 数据导入导出 | P2 | 4h | Excel批量操作 |
| 消息推送 | P2 | 4h | 预警通知 |
| 多店铺管理 | P2 | 16h | 连锁店管理 |

---

## 📁 文件结构规划

```
zhiguanjia-app/
├── lib/
│   ├── app/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── workflow_model.dart      # 状态流转模型 ✅
│   │   │   │   ├── staff_model.dart           # 职员模型 ✅
│   │   │   │   ├── permission_model.dart    # 权限模型 ✅
│   │   │   │   ├── warning_model.dart       # 预警模型
│   │   │   │   ├── finance_report_model.dart # 财务报表模型
│   │   │   │   └── log_model.dart           # 日志模型
│   │   │   └── providers/
│   │   │       ├── permission_provider.dart # 权限状态管理
│   │   │       └── staff_provider.dart      # 职员状态管理
│   │   ├── modules/
│   │   │   ├── staff/                   # 职员管理模块
│   │   │   │   ├── views/
│   │   │   │   │   ├── staff_list_view.dart
│   │   │   │   │   ├── staff_form_view.dart
│   │   │   │   │   ├── staff_detail_view.dart
│   │   │   │   │   └── department_view.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── staff_controller.dart
│   │   │   │   └── bindings/
│   │   │   │       └── staff_binding.dart
│   │   │   ├── permission/              # 权限管理模块
│   │   │   │   ├── views/
│   │   │   │   │   ├── role_list_view.dart
│   │   │   │   │   ├── role_form_view.dart
│   │   │   │   │   └── permission_assign_view.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── permission_controller.dart
│   │   │   │   └── bindings/
│   │   │   │       └── permission_binding.dart
│   │   │   ├── workflow/                # 工作流模块
│   │   │   │   ├── views/
│   │   │   │   │   ├── status_history_view.dart
│   │   │   │   │   └── approval_view.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── workflow_controller.dart
│   │   │   │   └── bindings/
│   │   │   │       └── workflow_binding.dart
│   │   │   ├── warning/                 # 库存预警模块
│   │   │   │   ├── views/
│   │   │   │   │   ├── warning_list_view.dart
│   │   │   │   │   └── warning_setting_view.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── warning_controller.dart
│   │   │   │   └── bindings/
│   │   │   │       └── warning_binding.dart
│   │   │   ├── report/                  # 报表模块
│   │   │   │   ├── views/
│   │   │   │   │   ├── finance_report_view.dart
│   │   │   │   │   ├── sales_report_view.dart
│   │   │   │   │   └── inventory_report_view.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── report_controller.dart
│   │   │   │   └── bindings/
│   │   │   │       └── report_binding.dart
│   │   │   └── setting/                 # 系统设置模块
│   │   │       ├── views/
│   │   │       │   ├── backup_view.dart
│   │   │       │   ├── log_view.dart
│   │   │       │   └── print_template_view.dart
│   │   │       ├── controllers/
│   │   │       │   └── setting_controller.dart
│   │   │       └── bindings/
│   │   │           └── setting_binding.dart
│   │   ├── services/
│   │   │   ├── workflow_service.dart    # 状态流转服务
│   │   │   ├── permission_service.dart  # 权限服务
│   │   │   ├── warning_service.dart     # 预警服务
│   │   │   ├── report_service.dart      # 报表服务
│   │   │   └── log_service.dart         # 日志服务
│   │   └── utils/
│   │       ├── permission_guard.dart    # 权限路由守卫
│   │       ├── print_util.dart          # 打印工具
│   │       └── backup_util.dart         # 备份工具
```

---

## 📅 开发时间表

### Day 1 (06-27) - 模型与基础

| 时间 | Thread-A | Thread-B | Thread-C | Thread-D | Thread-E |
|------|----------|----------|----------|----------|----------|
| 09:00 | ✅ 数据模型 | ✅ 数据模型 | ✅ 数据模型 | ✅ 数据模型 | ✅ 数据模型 |
| 10:00 | 服务层开发 | 服务层开发 | 服务层开发 | 服务层开发 | 服务层开发 |
| 12:00 | 🍽 午休 | 🍽 午休 | 🍽 午休 | 🍽 午休 | 🍽 午休 |
| 14:00 | 控制器开发 | 控制器开发 | 控制器开发 | 控制器开发 | 控制器开发 |
| 16:00 | UI页面开发 | UI页面开发 | UI页面开发 | UI页面开发 | UI页面开发 |
| 18:00 | 整合测试 | 整合测试 | 整合测试 | 整合测试 | 整合测试 |

### Day 2 (06-28) - 功能完善

| 时间 | 内容 |
|------|------|
| 全天 | P1功能开发 (打印、备份、来往账、日志) |
| 晚上 | 模块联调测试 |

### Day 3 (06-29) - 测试与优化

| 时间 | 内容 |
|------|------|
| 上午 | 端到端测试 |
| 下午 | Bug修复与优化 |
| 晚上 | 文档整理与交付 |

---

## 🧭 依赖关系

```
权限系统
    ↓ 依赖
职员管理 (需要角色分配)
    ↓ 依赖
单据流转 (需要审核权限)
    ↓ 依赖
操作日志 (记录操作人)
```

---

## ✅ 验收标准

### 功能验收

- [ ] 单据状态可正常流转
- [ ] 职员CRUD正常
- [ ] 角色权限配置生效
- [ ] 权限控制正常拦截
- [ ] 库存预警正常触发
- [ ] 财务报表数据准确
- [ ] 单据打印格式正确
- [ ] 数据备份恢复正常

### 代码质量

- [ ] 代码覆盖率 > 70%
- [ ] 所有功能有注释
- [ ] 端到端测试通过
- [ ] 无严重Bug

---

**计划制定人:** Hermes Agent  
**审核人:** 待确认  
**执行状态:** 🔧 进行中
