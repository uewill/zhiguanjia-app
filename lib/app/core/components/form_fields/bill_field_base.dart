import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 单据表单字段基类
/// 统一处理 TDesign 样式和交互逻辑
abstract class BillFieldBase extends StatelessWidget {
  final String label;
  final bool required;
  final bool readOnly;
  final String? hintText;
  final EdgeInsetsGeometry? padding;
  final Widget? suffix;
  final Widget? prefix;

  const BillFieldBase({
    super.key,
    required this.label,
    this.required = false,
    this.readOnly = false,
    this.hintText,
    this.padding,
    this.suffix,
    this.prefix,
  });

  /// 带星号的标签文本
  String get displayLabel => required ? '$label *' : label;

  /// 默认内边距
  EdgeInsets get defaultPadding => const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// 构建标签
  Widget buildLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (required)
          const Text(
            '* ',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        TDText(
          label,
          style: TextStyle(
            fontSize: 14,
            color: required ? Colors.red.shade700 : Colors.grey.shade700,
            fontWeight: required ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// 显示底部选择弹窗
  Future<T?> showSelectorBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required T? selectedValue,
    VoidCallback? onCreateNew,
    String? createNewText,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectorSheet<T>(
        title: title,
        items: items,
        itemBuilder: itemBuilder,
        selectedValue: selectedValue,
        onCreateNew: onCreateNew,
        createNewText: createNewText,
      ),
    );
  }

  /// 显示带搜索的选择弹窗
  Future<T?> showSearchSelectorBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required T? selectedValue,
    required String Function(T) searchKeyMapper,
    VoidCallback? onCreateNew,
    String? createNewText,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchSelectorSheet<T>(
        title: title,
        items: items,
        itemBuilder: itemBuilder,
        selectedValue: selectedValue,
        searchKeyMapper: searchKeyMapper,
        onCreateNew: onCreateNew,
        createNewText: createNewText,
      ),
    );
  }
}

/// 基础选择弹窗
class _SelectorSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final T? selectedValue;
  final VoidCallback? onCreateNew;
  final String? createNewText;

  const _SelectorSheet({
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.selectedValue,
    this.onCreateNew,
    this.createNewText,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动指示器
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TDText(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // 列表
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                      onTap: () => Navigator.pop(context, item),
                      title: itemBuilder(item),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFF2FC27D))
                          : null,
                    );
                  },
                ),
              ),
              // 新增按钮
              if (onCreateNew != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: TDButton(
                    text: createNewText ?? '新增$title',
                    theme: TDButtonTheme.primary,
                    size: TDButtonSize.large,
                    isBlock: true,
                    icon: TDIcons.add,
                    onTap: () {
                      Navigator.pop(context);
                      onCreateNew!();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 带搜索的选择弹窗
class _SearchSelectorSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final T? selectedValue;
  final String Function(T) searchKeyMapper;
  final VoidCallback? onCreateNew;
  final String? createNewText;

  const _SearchSelectorSheet({
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.selectedValue,
    required this.searchKeyMapper,
    this.onCreateNew,
    this.createNewText,
  });

  @override
  State<_SearchSelectorSheet<T>> createState() => _SearchSelectorSheetState<T>();
}

class _SearchSelectorSheetState<T> extends State<_SearchSelectorSheet<T>> {
  late List<T> filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        filteredItems = widget.items.where((item) {
          return widget.searchKeyMapper(item).toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动指示器
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TDText(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // 搜索框
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索${widget.title}...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              // 列表
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            TDText('无匹配结果', style: TextStyle(color: Colors.grey.shade400)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = item == widget.selectedValue;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                            onTap: () => Navigator.pop(context, item),
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
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: TDButton(
                    text: widget.createNewText ?? '新增${widget.title}',
                    theme: TDButtonTheme.primary,
                    size: TDButtonSize.large,
                    isBlock: true,
                    icon: TDIcons.add,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onCreateNew!();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
