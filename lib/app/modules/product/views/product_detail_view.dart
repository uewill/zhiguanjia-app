import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/product_model.dart';
import 'product_form_view.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;
  const ProductDetailView({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: '商品详情',
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        rightBarItems: [
          TDNavBarItem(
            iconWidget: const Icon(Icons.edit, color: Colors.white, size: 20),
            action: () => Get.to(() => ProductFormView(product: product)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBasicInfo(),
            _buildPriceStock(),
            if (product.barcode != null) _buildBarcode(),
            if (product.units != null && product.units!.isNotEmpty) _buildUnits(),
            if (product.hasSku && product.skus != null && product.skus!.isNotEmpty) _buildSkus(),
            if (product.attrs != null && product.attrs!.isNotEmpty) _buildAttrs(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      width: double.infinity,
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
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: TDText('📦', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TDText(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TDText('编码: ${product.code}', style: const TextStyle(color: Colors.grey)),
                    if (product.category != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TDText(product.category!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStock() {
    final isLowStock = product.stock <= product.minStock;
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
          const TDText('价格与库存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('进价', '¥${product.purchasePrice.toStringAsFixed(2)}', color: Colors.orange),
              ),
              Expanded(
                child: _buildInfoItem('售价', '¥${product.salePrice.toStringAsFixed(2)}', color: const Color(0xFF2FC27D)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('当前库存', '${product.stock} ${product.unit}', color: isLowStock ? Colors.red : Colors.blue),
              ),
              Expanded(
                child: _buildInfoItem('库存下限', '${product.minStock} ${product.unit}', color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TDText(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TDText(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildBarcode() {
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
          const TDText('条形码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.qr_code, size: 48, color: Colors.grey),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TDText(product.barcode!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const TDText('扫码识别', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnits() {
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
            children: [
              const Expanded(child: TDText('多单位管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const TDText('多单位', style: TextStyle(fontSize: 12, color: Color(0xFF7B1FA2))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...product.units!.map((unit) => Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TDText(unit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      TDText('1:${unit.ratio}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TDText('进价: ¥${unit.purchasePrice?.toStringAsFixed(2) ?? '-'}', style: const TextStyle(fontSize: 12)),
                      TDText('售价: ¥${unit.salePrice?.toStringAsFixed(2) ?? '-'}', style: const TextStyle(fontSize: 12, color: Color(0xFF2FC27D))),
                    ],
                  ),
                ),
                if (unit.barcode != null)
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 14, color: Colors.grey),
                      TDText(unit.barcode!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSkus() {
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
            children: [
              const Expanded(child: TDText('多规格SKU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TDText('${product.skus?.length ?? 0}个规格', style: const TextStyle(fontSize: 12, color: Color(0xFF1976D2))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...product.skus!.map((sku) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(sku.specText, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TDText('进价: ¥${sku.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12))),
                    Expanded(child: TDText('售价: ¥${sku.salePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF2FC27D)))),
                    Expanded(child: TDText('库存: ${sku.stock}', style: const TextStyle(fontSize: 12))),
                  ],
                ),
                if (sku.barcode != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 14, color: Colors.grey),
                      TDText(' ${sku.barcode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAttrs() {
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
          const TDText('自定义属性', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.attrs!.map((attr) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2FC27D).withOpacity(0.3)),
              ),
              child: TDText('${attr.name}: ${attr.value}', style: const TextStyle(fontSize: 13)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
