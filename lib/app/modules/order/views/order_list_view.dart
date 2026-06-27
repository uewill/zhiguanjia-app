import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/order_model.dart';
import '../controllers/order_controller.dart';

class OrderListView extends GetView<OrderController> {
  const OrderListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          _buildSearchBar(),
          Expanded(child: _buildOrderList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2FC27D),
        onPressed: controller.createOrder,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2FC27D),
      ),
      child: Row(
        children: [
          const TDText(
            '订单管理',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TDInput(
              controller: controller.searchController,
              hintText: '搜索订单号/客户',
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

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const TDText('暂无订单', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.filteredOrders.length,
        itemBuilder: (context, index) {
          final order = controller.filteredOrders[index];
          return _buildOrderCard(order);
        },
      );
    });
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () => controller.viewDetail(order),
      child: Container(
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
                  order.orderNo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TDText(
                    controller.getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  order.type == 'purchase' ? Icons.shopping_cart : Icons.sell,
                  size: 16,
                  color: const Color(0xFF86909C),
                ),
                const SizedBox(width: 6),
                TDText(
                  order.type == 'purchase' ? '采购单' : '销售单',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF86909C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TDText(
                  order.customerName,
                  style: const TextStyle(fontSize: 14),
                ),
                TDText(
                  '¥${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2FC27D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TDText(
              '${order.createTime.year}-${order.createTime.month.toString().padLeft(2, '0')}-${order.createTime.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF86909C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
