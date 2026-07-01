import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/product_model.dart';
import '../controllers/product_controller.dart';
import '../../../widgets/image_picker_widget.dart';

class ProductFormView extends StatefulWidget {
  final Product? product;
  const ProductFormView({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final barcodeController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final stockController = TextEditingController();
  final minStockController = TextEditingController();
  final categoryController = TextEditingController();
  final unitController = TextEditingController();
  late final ProductController controller;

  // 多单位
  final units = <ProductUnit>[].obs;

  // 多规格
  final hasSku = false.obs;
  final skuSpecs = <SkuSpec>[].obs;
  final skus = <ProductSku>[].obs;

  // 自定义属性
  final attrs = <ProductAttr>[].obs;
  
  // 商品图片列表
  final productImages = <String>[].obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      codeController.text = widget.product!.code;
      barcodeController.text = widget.product!.barcode ?? '';
      purchasePriceController.text = widget.product!.purchasePrice.toString();
      salePriceController.text = widget.product!.salePrice.toString();
      stockController.text = widget.product!.stock.toString();
      minStockController.text = widget.product!.minStock.toString();
      categoryController.text = widget.product!.category ?? '';
      unitController.text = widget.product!.unit;

      if (widget.product!.units != null) {
        units.value = List.from(widget.product!.units!);
      }
      hasSku.value = widget.product!.hasSku;
      if (widget.product!.skuSpecs != null) {
        skuSpecs.value = List.from(widget.product!.skuSpecs!);
      }
      if (widget.product!.skus != null) {
        skus.value = List.from(widget.product!.skus!);
      }
      if (widget.product!.attrs != null) {
        attrs.value = List.from(widget.product!.attrs!);
      }
      if (widget.product!.images != null) {
        productImages.value = List.from(widget.product!.images!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: widget.product == null ? '新增商品' : '编辑商品',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection('基本信息', [
              TDInput(
                controller: nameController,
                leftLabel: '商品名称',
                hintText: '请输入商品名称',
                backgroundColor: Colors.white,
              ),
              TDInput(
                controller: codeController,
                leftLabel: '商品编码',
                hintText: '请输入商品编码',
                backgroundColor: Colors.white,
              ),
              TDInput(
                controller: barcodeController,
                leftLabel: '条形码',
                hintText: '请输入条形码',
                backgroundColor: Colors.white,
                rightWidget: GestureDetector(
                  onTap: () => _showScanDialog(),
                  child: const TDText('📷', style: TextStyle(fontSize: 20)),
                ),
              ),
              TDInput(
                controller: categoryController,
                leftLabel: '分类',
                hintText: '请输入分类',
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Obx(() => ImagePickerWidget(
                images: productImages,
                onChanged: (images) => productImages.value = images,
                maxCount: 9,
                title: '商品图片',
              )),
            ]),
            _buildSection('价格与库存', [
              Row(
                children: [
                  Expanded(
                    child: TDInput(
                      controller: purchasePriceController,
                      leftLabel: '进价',
                      hintText: '进价',
                      inputType: TextInputType.number,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TDInput(
                      controller: salePriceController,
                      leftLabel: '售价',
                      hintText: '售价',
                      inputType: TextInputType.number,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TDInput(
                      controller: stockController,
                      leftLabel: '当前库存',
                      hintText: '当前库存',
                      inputType: TextInputType.number,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TDInput(
                      controller: minStockController,
                      leftLabel: '库存下限',
                      hintText: '库存下限',
                      inputType: TextInputType.number,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TDInput(
                controller: unitController,
                leftLabel: '基础单位',
                hintText: '如：瓶、个、支',
                backgroundColor: Colors.white,
              ),
            ]),
            _buildUnitsSection(),
            _buildSkuSection(),
            _buildAttrsSection(),
            const SizedBox(height: 32),
            TDButton(
              text: widget.product == null ? '保存' : '更新',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              isBlock: true,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TDText(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // 多单位管理
  Widget _buildUnitsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              const TDText('多单位管理', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: _addUnit,
                child: const TDText('+添加单位', style: TextStyle(color: Color(0xFF2FC27D))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TDText('支持多级单位（如：箱→瓶→支），各单位可设置独立条码', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Obx(() => units.isEmpty
              ? const Center(child: TDText('暂无辅助单位', style: TextStyle(color: Colors.grey)))
              : Column(
                  children: units.asMap().entries.map((entry) {
                    final index = entry.key;
                    final unit = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TDText('${unit.name} (1:${unit.ratio})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 2,
                            child: TDText('售￥${unit.salePrice ?? '-'}', style: const TextStyle(fontSize: 12)),
                          ),
                          if (unit.barcode != null)
                            Expanded(
                              flex: 2,
                              child: TDText('码:${unit.barcode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                          GestureDetector(
                            onTap: () => units.removeAt(index),
                            child: const Icon(Icons.delete, color: Colors.red, size: 20),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          ),
        ],
      ),
    );
  }

  // 多规格管理
  Widget _buildSkuSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              const TDText('多规格管理', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Obx(() => TDSwitch(
                isOn: hasSku.value,
                onChanged: (v) => hasSku.value = v,
              )),
            ],
          ),
          const SizedBox(height: 8),
          const TDText('开启后可设置多个规格（如：颜色、尺码等）', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Obx(() => hasSku.value ? _buildSkuConfig() : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildSkuConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TDText('规格维度', style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _addSkuSpec,
              child: const TDText('+添加维度', style: TextStyle(color: Color(0xFF2FC27D), fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => skuSpecs.isEmpty
            ? const TDText('暂无规格维度', style: TextStyle(color: Colors.grey))
            : Column(
                children: skuSpecs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final spec = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: TDText(spec.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                            GestureDetector(
                              onTap: () => skuSpecs.removeAt(index),
                              child: const Icon(Icons.delete, color: Colors.red, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TDText('可选值: ${spec.values.join(', ')}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }).toList(),
              ),
        ),
        const SizedBox(height: 16),
        if (skuSpecs.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TDText('SKU列表', style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _generateSkus,
                child: const TDText('生成SKU', style: TextStyle(color: Color(0xFF2FC27D), fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => skus.isEmpty
              ? const TDText('点击"生成SKU"创建规格组合', style: TextStyle(color: Colors.grey))
              : Column(
                  children: skus.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sku = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(sku.specText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(child: TDText('进价: ￥${sku.purchasePrice}', style: const TextStyle(fontSize: 12))),
                              Expanded(child: TDText('售价: ￥${sku.salePrice}', style: const TextStyle(fontSize: 12))),
                              Expanded(child: TDText('库存: ${sku.stock}', style: const TextStyle(fontSize: 12))),
                              if (sku.barcode != null)
                                TDText('码:${sku.barcode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          ),
        ],
      ],
    );
  }

  // 自定义属性
  Widget _buildAttrsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              const TDText('自定义属性', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: _addAttr,
                child: const TDText('+添加属性', style: TextStyle(color: Color(0xFF2FC27D))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TDText('如：品牌、产地、保质期、材质等', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Obx(() => attrs.isEmpty
              ? const Center(child: TDText('暂无自定义属性', style: TextStyle(color: Colors.grey)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: attrs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attr = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9F4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2FC27D).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TDText('${attr.name}: ${attr.value}', style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => attrs.removeAt(index),
                            child: const Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (nameController.text.isEmpty || codeController.text.isEmpty) {
      Get.snackbar('提示', '请填写商品名称和编码');
      return;
    }

    final data = {
      'name': nameController.text,
      'code': codeController.text,
      'barcode': barcodeController.text.isEmpty ? null : barcodeController.text,
      'purchasePrice': double.tryParse(purchasePriceController.text) ?? 0,
      'salePrice': double.tryParse(salePriceController.text) ?? 0,
      'stock': int.tryParse(stockController.text) ?? 0,
      'minStock': int.tryParse(minStockController.text) ?? 0,
      'category': categoryController.text.isEmpty ? null : categoryController.text,
      'unit': unitController.text.isEmpty ? '件' : unitController.text,
      'units': units.map((u) => u.toJson()).toList(),
      'hasSku': hasSku.value,
      'skuSpecs': skuSpecs.map((s) => s.toJson()).toList(),
      'skus': skus.map((s) => s.toJson()).toList(),
      'attrs': attrs.map((a) => a.toJson()).toList(),
      'images': productImages.toList(),
    };

    if (widget.product == null) {
      controller.createProduct(data);
    } else {
      controller.updateProduct(widget.product!.id, data);
    }
  }

  void _showScanDialog() {
    final codeController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('扫描条码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            const TDText('请将条码放入框内，自动扫描', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TDInput(
              controller: codeController,
              hintText: '或手动输入条码',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TDButton(
            text: '确认',
            theme: TDButtonTheme.primary,
            onTap: () {
              if (codeController.text.isNotEmpty) {
                barcodeController.text = codeController.text;
                Get.back();
                TDToast.showText('扫描成功', context: Get.context!);
              }
            },
          ),
        ],
      ),
    );
  }

  // 添加多单位
  void _addUnit() {
    final nameController = TextEditingController();
    final ratioController = TextEditingController(text: '1');
    final purchasePriceController = TextEditingController();
    final salePriceController = TextEditingController();
    final barcodeController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TDText('添加辅助单位', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TDInput(controller: nameController, leftLabel: '单位名称', hintText: '如：箱、打'),
            const SizedBox(height: 12),
            TDInput(controller: ratioController, leftLabel: '转换比例', hintText: '相当于基础单位的数量', inputType: TextInputType.number),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TDInput(controller: purchasePriceController, leftLabel: '进价', hintText: '可选', inputType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TDInput(controller: salePriceController, leftLabel: '售价', hintText: '可选', inputType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            TDInput(controller: barcodeController, leftLabel: '条码', hintText: '可选', rightWidget: const TDText('📷', style: TextStyle(fontSize: 20))),
            const SizedBox(height: 24),
            TDButton(
              text: '确认添加',
              theme: TDButtonTheme.primary,
              isBlock: true,
              onTap: () {
                if (nameController.text.isNotEmpty && ratioController.text.isNotEmpty) {
                  units.add(ProductUnit(
                    name: nameController.text,
                    ratio: double.tryParse(ratioController.text) ?? 1,
                    purchasePrice: double.tryParse(purchasePriceController.text),
                    salePrice: double.tryParse(salePriceController.text),
                    barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
                  ));
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 添加规格维度
  void _addSkuSpec() {
    final nameController = TextEditingController();
    final valuesController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TDText('添加规格维度', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TDInput(controller: nameController, leftLabel: '维度名称', hintText: '如：颜色、尺码、材质'),
            const SizedBox(height: 12),
            TDInput(controller: valuesController, leftLabel: '可选值', hintText: '用逗号分隔，如：红色,蓝色,黑色'),
            const SizedBox(height: 24),
            TDButton(
              text: '确认添加',
              theme: TDButtonTheme.primary,
              isBlock: true,
              onTap: () {
                if (nameController.text.isNotEmpty && valuesController.text.isNotEmpty) {
                  skuSpecs.add(SkuSpec(
                    name: nameController.text,
                    values: valuesController.text.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList(),
                  ));
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 生成SKU组合
  void _generateSkus() {
    if (skuSpecs.isEmpty) return;

    // 计算所有组合
    List<Map<String, String>> combinations = [{}];
    for (final spec in skuSpecs) {
      List<Map<String, String>> newCombinations = [];
      for (final combo in combinations) {
        for (final value in spec.values) {
          newCombinations.add({...combo, spec.name: value});
        }
      }
      combinations = newCombinations;
    }

    // 生成SKU列表
    skus.value = combinations.map((specs) => ProductSku(
      id: DateTime.now().millisecondsSinceEpoch.toString() + specs.hashCode.toString(),
      specs: specs,
      purchasePrice: double.tryParse(purchasePriceController.text) ?? 0,
      salePrice: double.tryParse(salePriceController.text) ?? 0,
      stock: 0,
    )).toList();

    Get.snackbar('成功', '已生成 ${skus.length} 个SKU组合');
  }

  // 添加自定义属性
  void _addAttr() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TDText('添加属性', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TDInput(controller: nameController, leftLabel: '属性名称', hintText: '如：品牌、产地、材质'),
            const SizedBox(height: 12),
            TDInput(controller: valueController, leftLabel: '属性值', hintText: '如：华为、中国、塑料'),
            const SizedBox(height: 24),
            TDButton(
              text: '确认添加',
              theme: TDButtonTheme.primary,
              isBlock: true,
              onTap: () {
                if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  attrs.add(ProductAttr(
                    name: nameController.text,
                    value: valueController.text,
                  ));
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
