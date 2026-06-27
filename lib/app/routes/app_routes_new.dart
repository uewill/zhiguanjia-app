// 新框架扩展路由 - 单据类和资料类页面使用抽象设计

part of 'app_pages.dart';

/// 新框架路径扩展
abstract class RoutesNew {
  RoutesNew._();
  
  // 采购单 - 新框架
  static const PURCHASE_ORDER_CREATE_NEW = '/purchase-order/create-new';
  
  // 销售单 - 新框架
  static const SALE_ORDER_CREATE_NEW = '/sale-order/create-new';
  
  // 调拨单 - 新框架
  static const TRANSFER_CREATE_NEW = '/transfer/create-new';
  
  // 资料类 - 新框架
  static const CUSTOMER_LIST_NEW = '/customer/list-new';
  static const CUSTOMER_FORM_NEW = '/customer/form-new';
  static const SUPPLIER_LIST_NEW = '/supplier/list-new';
  static const SUPPLIER_FORM_NEW = '/supplier/form-new';
  static const WAREHOUSE_LIST_NEW = '/warehouse/list-new';
  static const WAREHOUSE_FORM_NEW = '/warehouse/form-new';
  static const PRODUCT_LIST_NEW = '/product/list-new';
  static const PRODUCT_FORM_NEW = '/product/form-new';
}

abstract class _PathsNew {
  static const PURCHASE_ORDER_CREATE_NEW = '/purchase-order/create-new';
  static const SALE_ORDER_CREATE_NEW = '/sale-order/create-new';
  static const TRANSFER_CREATE_NEW = '/transfer/create-new';
  static const CUSTOMER_LIST_NEW = '/customer/list-new';
  static const CUSTOMER_FORM_NEW = '/customer/form-new';
  static const SUPPLIER_LIST_NEW = '/supplier/list-new';
  static const SUPPLIER_FORM_NEW = '/supplier/form-new';
  static const WAREHOUSE_LIST_NEW = '/warehouse/list-new';
  static const WAREHOUSE_FORM_NEW = '/warehouse/form-new';
  static const PRODUCT_LIST_NEW = '/product/list-new';
  static const PRODUCT_FORM_NEW = '/product/form-new';
}
