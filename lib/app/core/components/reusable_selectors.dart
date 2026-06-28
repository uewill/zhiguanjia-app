/// 可复用选择器组件
/// 用于客户、供应商、仓库、商品等选择

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 底部选择器布局
class BottomSelectorSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final T? selectedValue;
  final Function(T item)? onItemSelected;
  final VoidCallback? onCreateNew;
  final String? createNewText;
  final bool showSearch;
  final String? Function(T item)? searchKey;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const BottomSelectorSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.selectedValue,
    this.onItemSelected,
    this.onCreateNew,
    this.createNewText,
    this.showSearch = false,
    this.searchKey,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _BottomSelectorContent<T>(
        title: title,
        items: items,
        itemBuilder: itemBuilder,
        selectedValue: selectedValue,
        onItemSelected: onItemSelected,
        onCreateNew: onCreateNew,
        createNewText: createNewText,
        showSearch: showSearch,
        searchKey: searchKey,
        onRefresh: onRefresh,
        isLoading: isLoading,
      ),
    );
  }
}

class _BottomSelectorContent<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final T? selectedValue;
  final Function(T item)? onItemSelected;
  final VoidCallback? onCreateNew;
  final String? createNewText;
  final bool showSearch;
  final String? Function(T item)? searchKey;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const _BottomSelectorContent({
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.selectedValue,
    this.onItemSelected,
    this.onCreateNew,
    this.createNewText,
    this.showSearch = false,
    this.searchKey,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<_BottomSelectorContent<T>> createState() => _BottomSelectorContentState<T>();
}

class _BottomSelectorContentState<T> extends State<_BottomSelectorContent<T>> {
  late List<T> filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(covariant _BottomSelectorContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      setState(() {
        filteredItems = widget.items;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty || widget.searchKey == null) {
        filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        filteredItems = widget.items.where((item) {
          final key = widget.searchKey!(item);
          return key?.toLowerCase().contains(lowerQuery) ?? false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TDText(
                  widget.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.onRefresh,
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
        // 搜索框
        if (widget.showSearch && widget.searchKey != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TDInput(
              leftLabel: '',
              hintText: '搜索...',
              prefixIcon: const Icon(Icons.search),
              controller: _searchController,
              onChanged: _onSearchChanged,
              clearBtn: _searchController.text.isNotEmpty,
              onClearTap: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),
        // 列表
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          TDText('暂无数据', style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = item == widget.selectedValue;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: const Color(0xFF2FC27D).withOpacity(0.1),
                          onTap: () {
                            widget.onItemSelected?.call(item);
                            Get.back();
                          },
                          title: widget.itemBuilder(item),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Color(0xFF2FC27D))
                              : null,
                        );
                      },
                    ),
        ),
        // 新增按钮
        if (widget.onCreateNew != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TDButton(
              text: widget.createNewText ?? '新增',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              isBlock: true,
              icon: TDIcons.add,
              onTap: () {
                Get.back();
                widget.onCreateNew!();
              },
            ),
          ),
      ],
    );
  }
}

/// 客户选择器
class CustomerSelector {
  static void show({
    required List<dynamic> customers,
    required Function(dynamic customer) onSelected,
    dynamic selectedCustomer,
    VoidCallback? onCreateNew,
    VoidCallback? onRefresh,
    bool isLoading = false,
  }) {
    Get.bottomSheet(
      BottomSelectorSheet<dynamic>(
        title: '选择客户',
        items: customers,
        selectedValue: selectedCustomer,
        showSearch: true,
        searchKey: (c) => '${c.name} ${c.contact ?? ''} ${c.phone ?? ''}',
        isLoading: isLoading,
        onRefresh: onRefresh,
        onCreateNew: onCreateNew,
        createNewText: '新增客户',
        itemBuilder: (customer) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (customer.contact != null || customer.phone != null)
              Text(
                '${customer.contact ?? ''} ${customer.phone ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        onItemSelected: onSelected,
      ),
    );
  }
}

/// 供应商选择器
class SupplierSelector {
  static void show({
    required List<dynamic> suppliers,
    required Function(dynamic supplier) onSelected,
    dynamic selectedSupplier,
    VoidCallback? onCreateNew,
    VoidCallback? onRefresh,
    bool isLoading = false,
  }) {
    Get.bottomSheet(
      BottomSelectorSheet<dynamic>(
        title: '选择供应商',
        items: suppliers,
        selectedValue: selectedSupplier,
        showSearch: true,
        searchKey: (s) => '${s.name} ${s.contact ?? ''} ${s.phone ?? ''}',
        isLoading: isLoading,
        onRefresh: onRefresh,
        onCreateNew: onCreateNew,
        createNewText: '新增供应商',
        itemBuilder: (supplier) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (supplier.contact != null || supplier.phone != null)
              Text(
                '${supplier.contact ?? ''} ${supplier.phone ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        onItemSelected: onSelected,
      ),
    );
  }
}

/// 仓库选择器
class WarehouseSelector {
  static void show({
    required List<dynamic> warehouses,
    required Function(dynamic warehouse) onSelected,
    String title = '选择仓库',
    dynamic selectedWarehouse,
    VoidCallback? onRefresh,
    bool isLoading = false,
  }) {
    Get.bottomSheet(
      BottomSelectorSheet<dynamic>(
        title: title,
        items: warehouses,
        selectedValue: selectedWarehouse,
        isLoading: isLoading,
        onRefresh: onRefresh,
        itemBuilder: (warehouse) => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (warehouse.isDefault == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2FC27D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '默认',
                            style: TextStyle(fontSize: 10, color: Color(0xFF2FC27D)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (warehouse.address != null)
                    Text(
                      warehouse.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        onItemSelected: onSelected,
      ),
    );
  }
}

/// 商品选择器
class ProductSelector {
  static void show({
    required List<dynamic> products,
    required Function(dynamic product) onSelected,
    dynamic selectedProduct,
    VoidCallback? onCreateNew,
    VoidCallback? onRefresh,
    bool isLoading = false,
    String Function(dynamic)? priceGetter,
  }) {
    Get.bottomSheet(
      BottomSelectorSheet<dynamic>(
        title: '选择商品',
        items: products,
        selectedValue: selectedProduct,
        showSearch: true,
        searchKey: (p) => '${p.name} ${p.code ?? ''}',
        isLoading: isLoading,
        onRefresh: onRefresh,
        onCreateNew: onCreateNew,
        createNewText: '新增商品',
        itemBuilder: (product) => Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '编码: ${product.code ?? '-'} | 库存: ${product.stock ?? 0}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceGetter != null ? priceGetter(product) : '¥${product.salePrice ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFFF53F3F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.unit != null)
                  Text(
                    product.unit,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ],
        ),
        onItemSelected: onSelected,
      ),
    );
  }
}

/// 结算方式选择器
class SettlementSelector {
  static const List<Map<String, dynamic>> defaultOptions = [
    {'id': 'cash', 'name': '现金', 'icon': Icons.money},
    {'id': 'bank', 'name': '银行转账', 'icon': Icons.account_balance},
    {'id': 'wechat', 'name': '微信支付', 'icon': Icons.wechat},
    {'id': 'alipay', 'name': '支付宝', 'icon': Icons.payment},
    {'id': 'credit', 'name': '赪账', 'icon': Icons.credit_card},
  ];

  static void show({
    required Function(Map<String, dynamic> option) onSelected,
    String? selectedId,
    List<Map<String, dynamic>>? options,
  }) {
    final items = options ?? defaultOptions;
    Get.bottomSheet(
      BottomSelectorSheet<Map<String, dynamic>>(
        title: '选择结算方式',
        items: items,
        selectedValue: items.firstWhereOrNull((o) => o['id'] == selectedId),
        itemBuilder: (option) => Row(
          children: [
            Icon(option['icon'] as IconData?, color: const Color(0xFF2FC27D)),
            const SizedBox(width: 12),
            Text(option['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        onItemSelected: onSelected,
      ),
    );
  }
}
