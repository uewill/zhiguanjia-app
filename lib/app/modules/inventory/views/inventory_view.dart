import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: Obx(() => IndexedStack(
              index: controller.selectedTab.value,
              children: [
                _buildInventoryQueryTab(),
                _buildTransferTab(),
                _buildCheckTab(),
                _buildWarningTab(),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF2FC27D)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TDText('库存管理',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          TDButton(
            text: '调拨',
            theme: TDButtonTheme.light,
            size: TDButtonSize.small,
            onTap: controller.transferStock,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            controller.tabs.length,
            (index) => GestureDetector(
              onTap: () => controller.changeTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: controller.selectedTab.value == index
                          ? const Color(0xFF2FC27D)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: TDText(
                  controller.tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: controller.selectedTab.value == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: controller.selectedTab.value == index
                        ? const Color(0xFF2FC27D)
                        : const Color(0xFF86909C),
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  // 库存查询 Tab
  Widget _buildInventoryQueryTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredInventory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const TDText('暂无库存数据', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.filteredInventory.length,
              itemBuilder: (context, index) {
                final item = controller.filteredInventory[index];
                return _buildInventoryCard(item);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TDInput(
              controller: controller.searchController,
              hintText: '搜索商品名称',
              backgroundColor: const Color(0xFFF2F3F5),
              onChanged: (value) => controller.search(value),
            ),
          ),
          const SizedBox(width: 8),
          TDButton(
            text: '搜索',
            theme: TDButtonTheme.primary,
            size: TDButtonSize.small,
            onTap: () => controller.search(controller.searchController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              TDText(
                item['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2129),
                ),
              ),
              if (item['warning'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7D00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const TDText('预警',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFF7D00))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInventoryStat('库存数', '${item['quantity']}'),
              ),
              Expanded(
                child: _buildInventoryStat('锁定数', '${item['locked']}'),
              ),
              Expanded(
                child: _buildInventoryStat('可用数', '${item['available']}',
                    highlight: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TDText(
                '仓库: ${item['warehouse']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF86909C)),
              ),
              GestureDetector(
                onTap: () => controller.showAdjustDialog(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const TDText('调整',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2FC27D))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStat(String label, String value, {bool highlight = false}) {
    return Column(
      children: [
        TDText(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
        const SizedBox(height: 4),
        TDText(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: highlight ? const Color(0xFF2FC27D) : const Color(0xFF1D2129))),
      ],
    );
  }

  // 库存调拨 Tab
  Widget _buildTransferTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          TDButton(
            text: '新建调拨单',
            theme: TDButtonTheme.primary,
            onTap: controller.transferStock,
          ),
          const SizedBox(height: 24),
          TDButton(
            text: '新建调拨单',
            theme: TDButtonTheme.primary,
            onTap: controller.transferStock,
          ),
        ],
      ),
    );
  }

  // 库存盘点 Tab
  Widget _buildCheckTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          TDButton(
            text: '新建盘点单',
            theme: TDButtonTheme.primary,
            onTap: controller.checkStock,
          ),
          const SizedBox(height: 24),
          TDButton(
            text: '新建盘点单',
            theme: TDButtonTheme.primary,
            onTap: controller.checkStock,
          ),
        ],
      ),
    );
  }

  // 库存预警 Tab
  Widget _buildWarningTab() {
    return Obx(() {
      final warningItems = controller.inventoryList
          .where((item) => item['warning'] == true)
          .toList();

      if (warningItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
              const SizedBox(height: 16),
              const TDText('暂无预警信息', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: warningItems.length,
        itemBuilder: (context, index) {
          final item = warningItems[index];
          return _buildInventoryCard(item);
        },
      );
    });
  }
}
