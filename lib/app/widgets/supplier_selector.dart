import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/supplier_model.dart';
import '../services/api_service.dart';

class SupplierSelector extends StatefulWidget {
  const SupplierSelector({Key? key}) : super(key: key);

  @override
  State<SupplierSelector> createState() => _SupplierSelectorState();
}

class _SupplierSelectorState extends State<SupplierSelector> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Supplier> suppliers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final response = await _apiService.get('/suppliers');
      if (response.data['code'] == 200) {
        setState(() {
          suppliers = (response.data['data'] as List)
              .map((e) => Supplier.fromJson(e))
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('选择供应商', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _showCreateSupplier,
                  child: const Text('新增供应商'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : suppliers.isEmpty
                    ? const Center(child: Text('暂无供应商'))
                    : ListView.builder(
                        itemCount: suppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = suppliers[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF2fc27d),
                              child: Icon(Icons.business, color: Colors.white),
                            ),
                            title: Text(supplier.name),
                            subtitle: Text(supplier.contact ?? ''),
                            onTap: () => Navigator.pop(context, supplier),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showCreateSupplier() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增供应商'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '供应商名称'),
            ),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: '联系人'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: '联系电话'),
              
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.post('/suppliers', data: {
                  'name': nameController.text,
                  'contact': contactController.text,
                  'phone': phoneController.text,
                });
                Navigator.pop(context);
                _loadSuppliers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('创建失败: $e')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
