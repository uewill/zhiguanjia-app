import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'data_base.dart';
import 'data_controller.dart';

/// 资料列表页面模板 - 模板方法模式
abstract class DataListView<T extends DataItem> extends StatefulWidget {
  const DataListView({Key? key}) : super(key: key);

  @override
  State<DataListView<T>> createState() => DataListViewState<T>();
}

class DataListViewState<T extends DataItem> extends State<DataListView<T>> {
  late final DataController<T> controller;
  
  DataPageConfig get config => controller.config;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DataController<T>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TDNavBar(
        title: config.title,
        backgroundColor: const Color(0xFF2FC27D),
        titleColor: Colors.white,
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconColor: Colors.white,
            action: () => Get.back(),
          ),
        ],
        rightBarItems: [
          if (config.enableSearch)
            TDNavBarItem(
              icon: TDIcons.search,
              iconColor: Colors.white,
              action: _showSearchDialog,
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: _buildContent(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: config.primaryColor,
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      final items = controller.filteredItems;
      if (items.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(item);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          TDText(
            '暂无${config.singularName}',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TDButton(
            text: '添加${config.singularName}',
            theme: TDButtonTheme.primary,
            onTap: _navigateToCreate,
          ),
        ],
      ),
    );
  }

  /// 构建列表项卡片 - 子类可覆盖
  Widget _buildItemCard(T item) {
    return Dismissible(
      key: Key('${item.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(item),
      onDismissed: (_) => controller.deleteData(item.id!),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToEdit(item),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildLeadingIcon(item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TDText(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!item.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '已停用',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                      if (config.hasCode && item.code != null)
                        TDText(
                          '编码: ${item.code}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      _buildSubtitle(item),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建列表顶部图标 - 子类可覆盖
  Widget _buildLeadingIcon(T item) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: config.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(config.icon, color: config.primaryColor),
    );
  }

  /// 构建副标题 - 子类可覆盖
  Widget _buildSubtitle(T item) {
    return const SizedBox.shrink();
  }

  /// 确认删除
  Future<bool> _confirmDelete(T item) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 跳转创建页面
  void _navigateToCreate() {
    Get.toNamed(config.formRoute);
  }

  /// 跳转编辑页面
  void _navigateToEdit(T item) {
    Get.toNamed(config.formRoute, arguments: {'id': item.id});
  }

  /// 显示搜索对话框
  void _showSearchDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TDText(
              '搜索${config.singularName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TDInput(
              leftLabel: '',
              hintText: '输入搜索关键词',
              prefixIcon: const Icon(Icons.search),
              onChanged: controller.search,
            ),
            const SizedBox(height: 16),
            TDButton(
              text: '确定',
              theme: TDButtonTheme.primary,
              isBlock: true,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
