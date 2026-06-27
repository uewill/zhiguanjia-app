import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/customer_model.dart';
import '../services/api_service.dart';

class CustomerSelector extends StatefulWidget {
  const CustomerSelector({Key? key}) : super(key: key);

  @override
  State<CustomerSelector> createState() => _CustomerSelectorState();
}

class _CustomerSelectorState extends State<CustomerSelector> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Customer> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await _apiService.get('/customers');
      if (response.data['code'] == 200) {
        setState(() {
          customers = (response.data['data'] as List)
              .map((e) => Customer.fromJson(e))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
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
                const Text('选择客户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _showCreateCustomer,
                  child: const Text('新增客户'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : customers.isEmpty
                    ? const Center(child: Text('暂无客户'))
                    : ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2fc27d),
                              child: Text(
                                customer.name.substring(0, 1),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(customer.name),
                            subtitle: Text(customer.phone),
                            onTap: () => Navigator.pop(context, customer),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomer() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增客户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '客户名称'),
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
                await _apiService.post('/customers', data: {
                  'name': nameController.text,
                  'phone': phoneController.text,
                });
                Navigator.pop(context);
                _loadCustomers();
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
