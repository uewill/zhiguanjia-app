import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product_model.dart';

class SkuSelector extends StatefulWidget {
  final List<SkuSpec> specs;
  final Function(List<SkuSpec>) onSpecsChanged;

  const SkuSelector({
    Key? key,
    required this.specs,
    required this.onSpecsChanged,
  }) : super(key: key);

  @override
  State<SkuSelector> createState() => _SkuSelectorState();
}

class _SkuSelectorState extends State<SkuSelector> {
  late List<SkuSpec> specs;

  @override
  void initState() {
    super.initState();
    specs = List.from(widget.specs);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SKU规格管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...specs.asMap().entries.map((entry) {
            final index = entry.key;
            final spec = entry.value;
            return _buildSpecCard(index, spec);
          }).toList(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addSpec,
            icon: const Icon(Icons.add),
            label: const Text('添加规格'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onSpecsChanged(specs);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2fc27d),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(int index, SkuSpec spec) {
    final nameController = TextEditingController(text: spec.name);
    final valuesController = TextEditingController(text: spec.values.join(','));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '规格名称 (如: 颜色)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => specs[index].name = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => specs.removeAt(index));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valuesController,
              decoration: const InputDecoration(
                labelText: '可选值 (用逗号分隔)',
                border: OutlineInputBorder(),
                hintText: '红色,蓝色,黑色',
              ),
              onChanged: (v) => specs[index].values = v.split(',').map((e) => e.trim()).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _addSpec() {
    setState(() {
      specs.add(SkuSpec(name: '', values: []));
    });
  }
}
