import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product_model.dart';
import '../services/api_service.dart';

class ProductSelector extends StatefulWidget {
  const ProductSelector({Key? key}) : super(key: key);

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Product> products = [];
  bool isLoading = true;
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await _apiService.get('/products', queryParameters: {
        if (keyword.isNotEmpty) 'keyword': keyword,
      });
      if (response.data['code'] == 200) {
        setState(() {
          products = (response.data['data'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = products
        .where((p) => keyword.isEmpty || p.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Text('选择商品', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => keyword = v),
                    decoration: const InputDecoration(
                      hintText: '搜索商品',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('暂无商品'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade200,
                              child: product.imageUrl != null
                                  ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                            title: Text(product.name),
                            subtitle: Text('库存: ${product.stock} | 售价: ¥${product.salePrice.toStringAsFixed(2)}'),
                            onTap: () => _showQuantityDialog(product),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(Product product) {
    final quantityController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加: ${product.name}'),
        content: TextField(
          controller: quantityController,
          
          decoration: const InputDecoration(
            labelText: '数量',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              Navigator.pop(context);
              Navigator.pop(context, {
                'productId': product.id,
                'productName': product.name,
                'quantity': quantity,
                'unit': '瓶',
                'unitPrice': product.salePrice,
                'amount': quantity * product.salePrice,
              });
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
