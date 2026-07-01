import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../modules/sale_order/views/smart_sale_order_view.dart';
import '../routes/app_pages.dart';

/// 快速操作按钮组件
class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isNew;

  const QuickActionButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (isNew)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页快捷操作区
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem('智能开单', Icons.mic, const Color(0xFF2FC27D), () {
        Get.to(() => const SmartSaleOrderView());
      }, isNew: true),
      _ActionItem('扫码开单', Icons.qr_code_scanner, const Color(0xFF5B8FF9), () {
        Get.toNamed(Routes.SALE_ORDER_CREATE);
      }),
      _ActionItem('新增商品', Icons.add_box, const Color(0xFFF6BD16), () {
        Get.toNamed('/products/create');
      }),
      _ActionItem('库存查询', Icons.inventory_2, const Color(0xFF6DC8EC), () {
        Get.toNamed('/inventory');
      }),
      _ActionItem('客户管理', Icons.people, const Color(0xFF9266F9), () {
        Get.toNamed('/customers');
      }),
      _ActionItem('打印小票', Icons.receipt_long, const Color(0xFFFF9D4D), () {
        Get.toNamed('/print');
      }),
      _ActionItem('数据报表', Icons.bar_chart, const Color(0xFF5AD8A6), () {
        Get.toNamed('/reports');
      }),
      _ActionItem('更多功能', Icons.apps, const Color(0xFF969696), () {
        // TODO: 展开更多
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionButton(
          title: action.title,
          icon: action.icon,
          color: action.color,
          onTap: action.onTap,
          isNew: action.isNew,
        );
      },
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isNew;

  _ActionItem(this.title, this.icon, this.color, this.onTap, {this.isNew = false});
}

/// 悬浮快捷按钮
class FloatingQuickActions extends StatelessWidget {
  const FloatingQuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAction(Icons.mic, '语音', const Color(0xFF2FC27D), () {
            Get.to(() => const SmartSaleOrderView());
          }),
          const SizedBox(width: 8),
          _buildAction(Icons.camera_alt, '拍照', const Color(0xFF5B8FF9), () {
            Get.to(() => const SmartSaleOrderView());
          }),
          const SizedBox(width: 8),
          _buildAction(Icons.add, '开单', const Color(0xFFF6BD16), () {
            Get.toNamed(Routes.SALE_ORDER_CREATE);
          }),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

/// 快速搜索栏
class QuickSearchBar extends StatelessWidget {
  final Function(String)? onSearch;
  final VoidCallback? onScan;
  final String? hintText;

  const QuickSearchBar({
    Key? key,
    this.onSearch,
    this.onScan,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: hintText ?? '搜索商品、客户、订单...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: onSearch,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onScan != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onScan,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2FC27D),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 智能提示组件
class SmartSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String)? onTap;

  const SmartSuggestions({
    Key? key,
    required this.suggestions,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[600], size: 16),
              const SizedBox(width: 4),
              Text(
                '智能推荐',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => onTap?.call(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2FC27D)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
