import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'bill_type.dart';
import 'bill_controller.dart';
import '../components/index.dart';

/// 统一单据页面模板 (使用新组件库)
/// 支持表头、表尾、明细的统一配置
abstract class UnifiedBillPage<T extends BillCreateController> extends StatefulWidget {
  const UnifiedBillPage({super.key});

  @override
  State<UnifiedBillPage<T>> createState() => UnifiedBillPageState<T>();
}

class UnifiedBillPageState<T extends BillCreateController> extends State<UnifiedBillPage<T>> {
  late final T controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<T>();
  }

  @override
  Widget build(BuildContext context) {
    final billType = controller.billType;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: billType.title,
        backgroundColor: billType.primaryColor,
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 表头区域
                  _buildHeaderSection(),
                  const SizedBox(height: 16),

                  // 明细区域
                  _buildItemsSection(),
                  const SizedBox(height: 16),

                  // 备注
                  _buildRemarkSection(),
                ],
              ),
            ),
          ),

          // 表尾区域
          _buildFooterSection(),
        ],
      ),
    );
  }

  /// 构建表头区域
  Widget _buildHeaderSection() {
    final billType = controller.billType;
    final fields = <BillHeaderField>[];

    // 单号
    fields.add(BillHeaderField(
      key: 'billNo',
      label: '单号',
      type: BillHeaderFieldType.text,
      placeholder: '系统自动生成',
      onChanged: (v) {},
    ));

    // 日期
    fields.add(BillHeaderField(
      key: 'billDate',
      label: '业务日期',
      type: BillHeaderFieldType.date,
      required: true,
      value: controller.billDate.value,
      onChanged: (v) => controller.setBillDate(v),
    ));

    // 预期日期（如果需要）
    if (billType.showExpectedDate) {
      fields.add(BillHeaderField(
        key: 'expectedDate',
        label: billType.expectedDateLabel ?? '预期日期',
        type: BillHeaderFieldType.date,
        value: controller.expectedDate.value,
        onChanged: (v) => controller.setExpectedDate(v),
      ));
    }

    // 仓库选择
    if (billType.requiresWarehouse) {
      if (billType.code == 'transfer') {
        // 调拨单：出入库
        fields.add(BillHeaderField(
          key: 'fromWarehouse',
          label: '调出仓库',
          type: BillHeaderFieldType.warehouse,
          required: true,
          icon: Icons.warehouse_outlined,
          iconColor: Colors.orange,
          value: controller.selectedWarehouse.value,
          onTap: () => _showWarehouseSelector(isFrom: true),
        ));
        fields.add(BillHeaderField(
          key: 'toWarehouse',
          label: '调入仓库',
          type: BillHeaderFieldType.warehouse,
          required: true,
          icon: Icons.warehouse,
          iconColor: const Color(0xFF2FC27D),
          value: controller.selectedToWarehouse.value,
          onTap: () => _showWarehouseSelector(isFrom: false),
        ));
      } else {
        // 普通单据：单个仓库
        fields.add(BillHeaderField(
          key: 'warehouse',
          label: billType.warehouseLabel,
          type: BillHeaderFieldType.warehouse,
          required: true,
          icon: Icons.warehouse,
          iconColor: const Color(0xFF2FC27D),
          value: controller.selectedWarehouse.value,
          onTap: () => _showWarehouseSelector(),
        ));
      }
    }

    // 往来单位选择
    if (billType.requiresPartner) {
      fields.add(BillHeaderField(
        key: 'partner',
        label: billType.partnerLabel!,
        type: BillHeaderFieldType.partner,
        required: true,
        icon: Icons.business,
        iconColor: Colors.blue,
        value: controller.selectedPartner.value,
        onTap: () => _showPartnerSelector(),
      ));
    }

    // 经办人/业务员（如果需要）
    if (billType.requiresSalesman) {
      fields.add(BillHeaderField(
        key: 'salesman',
        label: billType.salesmanLabel ?? '经办人',
        type: BillHeaderFieldType.partner,
        icon: Icons.person_outline,
        iconColor: Colors.purple,
        value: controller.selectedSalesman.value,
        onTap: () => _showSalesmanSelector(),
      ));
    }

    return BillHeader(fields: fields);
  }

  /// 构建明细区域
  Widget _buildItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.billType.itemsLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TDButton(
                text: '添加商品',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.small,
                icon: TDIcons.add,
                onTap: () => _showProductPicker(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 明细列表
          Obx(() {
            if (controller.items.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return _buildBillItem(index, item);
              },
            );
          }),
        ],
      ),
    );
  }

  /// 构建单条明细
  Widget _buildBillItem(int index, BillItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品名称和删除按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => controller.removeItem(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // 编码和单位
          if (item.productCode != null) ...[
            const SizedBox(height: 4),
            Text(
              '${item.productCode} | ${item.unit}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],

          const SizedBox(height: 12),

          // 数量、单价、金额
          Row(
            children: [
              // 数量输入
              Expanded(
                flex: 2,
                child: _buildNumberInput(
                  label: '数量',
                  value: item.quantity.toDouble(),
                  suffix: item.unit,
                  onChanged: (v) => controller.updateItemQuantity(index, v.toInt()),
                ),
              ),
              const SizedBox(width: 8),

              // 单价输入
              Expanded(
                flex: 2,
                child: _buildNumberInput(
                  label: '单价',
                  value: item.price ?? 0,
                  prefix: '¥',
                  onChanged: (v) => controller.updateItemPrice(index, v),
                ),
              ),
              const SizedBox(width: 8),

              // 金额显示
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('金额', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      '¥${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF53F3F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('暂无商品', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showProductPicker(),
            child: const Text('点击添加'),
          ),
        ],
      ),
    );
  }

  /// 数字输入框
  Widget _buildNumberInput({
    required String label,
    required double value,
    String? prefix,
    String? suffix,
    required ValueChanged<double> onChanged,
  }) {
    final textController = TextEditingController(
      text: value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Text(prefix, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 2),
              ],
              Expanded(
                child: TextField(
                  controller: textController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Text(suffix, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 备注区域
  Widget _buildRemarkSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('备注', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: controller.remark.value),
            decoration: InputDecoration(
              hintText: '添加备注说明...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 2,
            onChanged: (v) => controller.remark.value = v,
          ),
        ],
      ),
    );
  }

  /// 表尾区域
  Widget _buildFooterSection() {
    final billType = controller.billType;

    // 根据单据类型选择不同的表尾
    if (billType.showAmount) {
      // 有金额的单据（销售、采购）
      return Obx(() => OrderBillFooter(
        totalQuantity: controller.totalQuantity,
        totalAmount: controller.totalAmount,
        discountAmount: controller.discountAmount.value,
        paidAmount: controller.paidAmount.value,
        onDiscountChanged: (v) => controller.discountAmount.value = v,
        onPaidChanged: (v) => controller.paidAmount.value = v,
        submitText: '保存${billType.name}',
        onSubmit: () => _submit(),
      ));
    } else {
      // 无金额的单据（入库、出库、调拨）- 隐藏金额显示
      return Obx(() => SimpleBillFooter(
        totalQuantity: controller.totalQuantity,
        totalAmount: 0, // 入库/出库单通常不显示金额
        submitText: '确认${billType.name}',
        onSubmit: () => _submit(),
      ));
    }
  }

  /// 显示仓库选择器
  void _showWarehouseSelector({bool isFrom = true}) {
    // 子类实现
  }

  /// 显示往来单位选择器
  void _showPartnerSelector() {
    // 子类实现
  }

  /// 显示经办人选择器
  void _showSalesmanSelector() {
    // 子类实现
  }

  /// 显示商品选择器
  void _showProductPicker() {
    // 子类实现
  }

  /// 提交单据
  Future<void> _submit() async {
    final success = await controller.createBill();
    if (success) {
      Get.back();
      Get.snackbar('成功', '${controller.billType.name}创建成功');
    }
  }
}

/// 扩展方法
extension BillTypeExtension on BillType {
  bool get showExpectedDate => ['purchase_order', 'sale_order'].contains(code);
  bool get showAmount => ['sale_order', 'purchase_order', 'retail_sale'].contains(code);
  bool get requiresSalesman => ['sale_order', 'retail_sale'].contains(code);

  String? get expectedDateLabel {
    switch (code) {
      case 'purchase_order':
        return '预计到货日期';
      case 'sale_order':
        return '预计发货日期';
      default:
        return null;
    }
  }

  String? get salesmanLabel {
    switch (code) {
      case 'sale_order':
        return '销售员';
      case 'retail_sale':
        return '收银员';
      default:
        return '经办人';
    }
  }
}
