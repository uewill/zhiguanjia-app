import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 资料类页面类型
enum DataPageType {
  customer,    // 客户
  supplier,    // 供应商
  warehouse,   // 仓库
  product,     // 商品
  category,    // 分类
  account,     // 账户
  unit,        // 单位
}

/// 资料项基类 - 所有资料类数据的基类
abstract class DataItem {
  int? get id;
  String get name;
  String? get code;
  bool get isActive;
}

/// 资料页面配置 - 策略模式
class DataPageConfig {
  final DataPageType type;
  final String title;
  final String singularName;
  final IconData icon;
  final String apiEndpoint;
  final String formRoute;
  final Color primaryColor;
  final bool hasCode;
  final bool hasPhone;
  final bool hasAddress;
  final bool hasRemark;
  final bool enableSearch;
  final bool enableFilter;
  final List<String> searchFields;
  final String? parentType; // 用于分类类型

  const DataPageConfig({
    required this.type,
    required this.title,
    required this.singularName,
    required this.icon,
    required this.apiEndpoint,
    required this.formRoute,
    this.primaryColor = const Color(0xFF2FC27D),
    this.hasCode = false,
    this.hasPhone = false,
    this.hasAddress = false,
    this.hasRemark = true,
    this.enableSearch = true,
    this.enableFilter = false,
    this.searchFields = const ['name'],
    this.parentType,
  });

  /// 客户配置
  static const customer = DataPageConfig(
    type: DataPageType.customer,
    title: '客户管理',
    singularName: '客户',
    icon: Icons.people,
    apiEndpoint: '/customers',
    formRoute: '/customer/form',
    hasPhone: true,
    hasAddress: true,
    searchFields: ['name', 'contact', 'phone'],
  );

  /// 供应商配置
  static const supplier = DataPageConfig(
    type: DataPageType.supplier,
    title: '供应商管理',
    singularName: '供应商',
    icon: Icons.business,
    apiEndpoint: '/suppliers',
    formRoute: '/supplier/form',
    hasPhone: true,
    hasAddress: true,
    searchFields: ['name', 'contact', 'phone'],
  );

  /// 仓库配置
  static const warehouse = DataPageConfig(
    type: DataPageType.warehouse,
    title: '仓库管理',
    singularName: '仓库',
    icon: Icons.warehouse,
    apiEndpoint: '/warehouses',
    formRoute: '/warehouse/form',
    hasAddress: true,
    searchFields: ['name', 'address'],
  );

  /// 商品配置
  static const product = DataPageConfig(
    type: DataPageType.product,
    title: '商品管理',
    singularName: '商品',
    icon: Icons.inventory_2,
    apiEndpoint: '/products',
    formRoute: '/product/form',
    hasCode: true,
    enableSearch: true,
    enableFilter: true,
    searchFields: ['name', 'code', 'barcode'],
  );

  /// 分类配置
  static const category = DataPageConfig(
    type: DataPageType.category,
    title: '分类管理',
    singularName: '分类',
    icon: Icons.folder,
    apiEndpoint: '/categories',
    formRoute: '/category/form',
    hasCode: true,
  );
}
