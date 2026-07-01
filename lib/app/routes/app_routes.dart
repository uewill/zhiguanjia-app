part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const PRODUCT_LIST = _Paths.PRODUCT_LIST;
  static const PRODUCT_FORM = _Paths.PRODUCT_FORM;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const CUSTOMER_LIST = _Paths.CUSTOMER_LIST;
  static const ORDER_LIST = _Paths.ORDER_LIST;
  static const ORDER_CREATE = _Paths.ORDER_CREATE;
  static const ORDER_FORM = _Paths.ORDER_FORM;
  static const ORDER_DETAIL = _Paths.ORDER_DETAIL;
  static const PURCHASE_CREATE = _Paths.PURCHASE_CREATE;
  static const SUPPLIER_LIST = _Paths.SUPPLIER_LIST;
  static const SUPPLIER_FORM = _Paths.SUPPLIER_FORM;
  static const INVENTORY_LIST = _Paths.INVENTORY_LIST;
  static const INVENTORY = _Paths.INVENTORY;
  static const FINANCE = _Paths.FINANCE;
  static const STAFF_LIST = _Paths.STAFF_LIST;
  static const STAFF_FORM = _Paths.STAFF_FORM;
  static const STAFF_DETAIL = _Paths.STAFF_DETAIL;
  static const WORKFLOW_HISTORY = _Paths.WORKFLOW_HISTORY;
  static const WORKFLOW_APPROVAL = _Paths.WORKFLOW_APPROVAL;
  static const PERMISSION_LIST = _Paths.PERMISSION_LIST;
  static const PERMISSION_ASSIGN = _Paths.PERMISSION_ASSIGN;
  static const WARNING_LIST = _Paths.WARNING_LIST;
  static const FINANCE_REPORT = _Paths.FINANCE_REPORT;
  static const BACKUP = _Paths.BACKUP;
  static const PRINT_TEMPLATES = _Paths.PRINT_TEMPLATES;
  static const PRINT_TEMPLATE_EDIT = _Paths.PRINT_TEMPLATE_EDIT;
  static const PRINT_PREVIEW = _Paths.PRINT_PREVIEW;
  static const PRINT_SETTINGS = _Paths.PRINT_SETTINGS;
  static const BARCODE_PRINT = _Paths.BARCODE_PRINT;
  static const BARCODE_TEMPLATES = _Paths.BARCODE_TEMPLATES;
  static const BARCODE_TEMPLATE_EDIT = _Paths.BARCODE_TEMPLATE_EDIT;

  // P0 差异功能路径
  static const WAREHOUSE_LIST = _Paths.WAREHOUSE_LIST;
  static const WAREHOUSE_FORM = _Paths.WAREHOUSE_FORM;
  static const STOCK_CHECK_LIST = _Paths.STOCK_CHECK_LIST;
  static const STOCK_CHECK_CREATE = _Paths.STOCK_CHECK_CREATE;
  static const TRANSFER_LIST = _Paths.TRANSFER_LIST;
  static const TRANSFER_CREATE = _Paths.TRANSFER_CREATE;
  static const PURCHASE_ORDER_LIST = _Paths.PURCHASE_ORDER_LIST;
  static const PURCHASE_ORDER_CREATE = _Paths.PURCHASE_ORDER_CREATE;
  static const SALE_ORDER_LIST = _Paths.SALE_ORDER_LIST;
  static const SALE_ORDER_CREATE = _Paths.SALE_ORDER_CREATE;
  static const SMART_SALE_ORDER = _Paths.SMART_SALE_ORDER;
  static const EXCEL_IMPORT_EXPORT = _Paths.EXCEL_IMPORT_EXPORT;
}

abstract class _Paths {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const PRODUCT_LIST = '/product/list';
  static const PRODUCT_FORM = '/product/form';
  static const PRODUCT_DETAIL = '/product/detail';
  static const CUSTOMER_LIST = '/customer/list';
  static const ORDER_LIST = '/order/list';
  static const ORDER_CREATE = '/order/create';
  static const ORDER_FORM = '/order/form';
  static const ORDER_DETAIL = '/order/detail';
  static const PURCHASE_CREATE = '/purchase/create';
  static const SUPPLIER_LIST = '/supplier/list';
  static const SUPPLIER_FORM = '/supplier/form';
  static const INVENTORY_LIST = '/inventory/list';
  static const INVENTORY = '/inventory';
  static const FINANCE = '/finance';
  static const STAFF_LIST = '/staff/list';
  static const STAFF_FORM = '/staff/form';
  static const STAFF_DETAIL = '/staff/detail';
  static const WORKFLOW_HISTORY = '/workflow/history';
  static const WORKFLOW_APPROVAL = '/workflow/approval';
  static const PERMISSION_LIST = '/permission/list';
  static const PERMISSION_ASSIGN = '/permission/assign';
  static const WARNING_LIST = '/warning/list';
  static const FINANCE_REPORT = '/report/finance';
  static const BACKUP = '/backup';
  static const PRINT_TEMPLATES = '/print/templates';
  static const PRINT_TEMPLATE_EDIT = '/print/template/edit';
  static const PRINT_PREVIEW = '/print/preview';
  static const PRINT_SETTINGS = '/print/settings';
  static const BARCODE_PRINT = '/barcode/print';
  static const BARCODE_TEMPLATES = '/barcode/templates';
  static const BARCODE_TEMPLATE_EDIT = '/barcode/template/edit';

  // P0 差异功能路径
  static const WAREHOUSE_LIST = '/warehouse/list';
  static const WAREHOUSE_FORM = '/warehouse/form';
  static const STOCK_CHECK_LIST = '/stock-check/list';
  static const STOCK_CHECK_CREATE = '/stock-check/create';
  static const TRANSFER_LIST = '/transfer/list';
  static const TRANSFER_CREATE = '/transfer/create';
  static const PURCHASE_ORDER_LIST = '/purchase-order/list';
  static const PURCHASE_ORDER_CREATE = '/purchase-order/create';
  static const SALE_ORDER_LIST = '/sale-order/list';
  static const SALE_ORDER_CREATE = '/sale-order/create';
  static const SMART_SALE_ORDER = '/sale-order/smart';
  static const EXCEL_IMPORT_EXPORT = '/excel/import-export';
}
