import 'package:get/get.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/product/bindings/product_binding.dart';
import '../modules/product/views/product_list_view.dart';
import '../modules/product/views/product_form_view.dart';
import '../modules/product/views/product_detail_view.dart';
import '../modules/customer/bindings/customer_binding.dart';
import '../modules/customer/views/customer_list_view.dart';
import '../modules/order/bindings/order_binding.dart';
import '../modules/order/bindings/unified_order_binding.dart';
import '../modules/order/views/order_list_view.dart';
import '../modules/order/views/order_create_view.dart';
import '../modules/order/views/order_form_view.dart';
import '../modules/order/views/order_detail_view.dart';
import '../modules/order/controllers/order_detail_controller.dart';
import '../modules/order/controllers/unified_sale_order_controller.dart';
import '../modules/order/controllers/unified_purchase_order_controller.dart';
import '../modules/order/controllers/unified_transfer_order_controller.dart';
import '../modules/purchase/views/purchase_create_view.dart';
import '../modules/purchase/bindings/purchase_binding.dart';
import '../modules/supplier/views/supplier_list_view.dart';
import '../modules/supplier/views/supplier_form_view.dart';
import '../modules/supplier/bindings/supplier_binding.dart';
import '../modules/inventory/views/inventory_list_view.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/finance/views/finance_view.dart';
import '../modules/finance/bindings/finance_binding.dart';
import '../modules/staff/views/staff_list_view.dart';
import '../modules/staff/bindings/staff_binding.dart';
import '../modules/permission/views/role_list_view.dart';
import '../modules/permission/views/permission_assign_view.dart';
import '../modules/permission/bindings/permission_binding.dart';
import '../modules/warning/views/warning_list_view.dart';
import '../modules/warning/bindings/warning_binding.dart';
import '../modules/backup/bindings/backup_binding.dart';
import '../modules/backup/views/backup_view.dart';
import '../modules/report/bindings/finance_report_binding.dart';
import '../modules/report/views/finance_report_view.dart';
import '../modules/workflow/bindings/workflow_binding.dart';
import '../modules/print/views/print_template_list_view.dart';
import '../modules/print/views/print_template_editor_view.dart';
import '../modules/print/views/print_preview_view.dart';
import '../modules/print/controllers/print_template_controller.dart';
import '../modules/barcode/views/barcode_template_list_view.dart';
import '../modules/barcode/views/barcode_print_view.dart';
import '../modules/barcode/views/barcode_template_editor_view.dart';
import '../modules/barcode/views/barcode_template_editor_view.dart';
import '../modules/barcode/views/barcode_template_editor_view.dart';

// 新框架页面 - 采购单
import '../modules/purchase_order/views/purchase_order_create_view_new.dart';
import '../modules/purchase_order/controllers/purchase_order_controller_new.dart';
// 新框架页面 - 销售单
import '../modules/sale_order/views/sale_order_create_view_new.dart';
import '../modules/sale_order/controllers/sale_order_controller_new.dart';
// 新框架页面 - 调拨单
import '../modules/transfer/views/transfer_create_view_new.dart';
import '../modules/transfer/controllers/transfer_controller_new.dart';
// 新框架页面 - 资料类
import '../modules/customer/views/customer_list_view_new.dart';
import '../modules/customer/views/customer_form_view_new.dart';
import '../modules/customer/controllers/customer_controller_new.dart';
import '../modules/customer/controllers/customer_form_controller.dart';

// P0 差异功能 - 仓库/盘点/调拨/订单
import '../modules/warehouse/views/warehouse_list_view.dart';
import '../modules/warehouse/views/warehouse_form_view.dart';
import '../modules/warehouse/controllers/warehouse_controller.dart';
import '../modules/inventory/views/stock_check_list_view.dart';
import '../modules/inventory/views/stock_check_create_view.dart';
import '../modules/inventory/controllers/stock_check_controller.dart';
import '../modules/transfer/views/transfer_list_view.dart';
import '../modules/transfer/views/transfer_create_view.dart';
import '../modules/transfer/controllers/transfer_controller.dart';
import '../modules/purchase_order/views/purchase_order_list_view.dart';
import '../modules/purchase_order/views/purchase_order_create_view.dart';
import '../modules/purchase_order/controllers/purchase_order_controller.dart';
import '../modules/sale_order/views/sale_order_list_view.dart';
import '../modules/sale_order/views/sale_order_create_view.dart';
import '../modules/sale_order/views/smart_sale_order_view.dart';
import '../modules/sale_order/controllers/sale_order_controller.dart';
// Excel导入导出
import '../modules/excel/views/excel_import_export_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_LIST,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_FORM,
      page: () => const ProductFormView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => ProductDetailView(product: Get.arguments),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_LIST,
      page: () => const CustomerListView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_LIST,
      page: () => const OrderListView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_CREATE,
      page: () => const OrderCreateView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_FORM,
      page: () => const OrderFormView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: _Paths.PURCHASE_CREATE,
      page: () => const PurchaseCreateView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: _Paths.SUPPLIER_LIST,
      page: () => const SupplierListView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: _Paths.SUPPLIER_FORM,
      page: () => const SupplierFormView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY_LIST,
      page: () => const InventoryListView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE,
      page: () => const FinanceView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_LIST,
      page: () => const StaffListView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: _Paths.PERMISSION_LIST,
      page: () => const RoleListView(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: _Paths.PERMISSION_ASSIGN,
      page: () => const PermissionAssignView(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: _Paths.WARNING_LIST,
      page: () => const WarningListView(),
      binding: WarningBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_REPORT,
      page: () => const FinanceReportView(),
      binding: FinanceReportBinding(),
    ),
    GetPage(
      name: _Paths.BACKUP,
      page: () => const BackupView(),
      binding: BackupBinding(),
    ),
    GetPage(
      name: _Paths.PRINT_TEMPLATES,
      page: () => const PrintTemplateListView(),
    ),
    GetPage(
      name: _Paths.PRINT_TEMPLATE_EDIT,
      page: () => const PrintTemplateEditorView(),
    ),
    GetPage(
      name: _Paths.PRINT_PREVIEW,
      page: () => const PrintPreviewView(),
    ),
    GetPage(
      name: _Paths.PRINT_SETTINGS,
      page: () => const PrintSettingsView(),
    ),
    GetPage(
      name: _Paths.BARCODE_PRINT,
      page: () => const BarcodePrintView(),
    ),
    GetPage(
      name: _Paths.BARCODE_TEMPLATES,
      page: () => const BarcodeTemplateListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BarcodeTemplateController());
      }),
    ),
    GetPage(
      name: _Paths.BARCODE_TEMPLATE_EDIT,
      page: () => const BarcodeTemplateEditorView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BarcodeTemplateEditorController());
      }),
    ),
    // P0 差异功能路由
    // 仓库管理
    GetPage(
      name: _Paths.WAREHOUSE_LIST,
      page: () => const WarehouseListView(),
    ),
    GetPage(
      name: _Paths.WAREHOUSE_FORM,
      page: () => const WarehouseFormView(),
    ),
    // 库存盘点
    GetPage(
      name: _Paths.STOCK_CHECK_LIST,
      page: () => const StockCheckListView(),
    ),
    GetPage(
      name: _Paths.STOCK_CHECK_CREATE,
      page: () => const StockCheckCreateView(),
    ),
    // 调拨管理 - 使用统一控制器
    GetPage(
      name: _Paths.TRANSFER_LIST,
      page: () => const TransferListView(),
      binding: TransferOrderBinding(),
    ),
    GetPage(
      name: _Paths.TRANSFER_CREATE,
      page: () => const TransferCreateView(),
      binding: TransferOrderBinding(),
    ),
    // 采购订单 - 使用统一控制器
    GetPage(
      name: _Paths.PURCHASE_ORDER_LIST,
      page: () => const PurchaseOrderListView(),
      binding: PurchaseOrderBinding(),
    ),
    GetPage(
      name: _Paths.PURCHASE_ORDER_CREATE,
      page: () => const PurchaseOrderCreateView(),
      binding: PurchaseOrderBinding(),
    ),
    // 销售订单 - 使用统一控制器
    GetPage(
      name: _Paths.SALE_ORDER_LIST,
      page: () => const SaleOrderListView(),
      binding: SaleOrderBinding(),
    ),
    GetPage(
      name: _Paths.SALE_ORDER_CREATE,
      page: () => const SaleOrderCreateView(),
      binding: SaleOrderBinding(),
    ),
    GetPage(
      name: _Paths.SMART_SALE_ORDER,
      page: () => const SmartSaleOrderView(),
    ),
    // Excel导入导出
    GetPage(
      name: _Paths.EXCEL_IMPORT_EXPORT,
      page: () => const ExcelImportExportView(),
    ),
    
    // ==================== 新框架路由 (基于设计模式重构) ====================
    // 采购单 - 新框架
    GetPage(
      name: '/purchase-order/create-new',
      page: () => const PurchaseOrderCreateViewNew(),
      binding: BindingsBuilder(() {
        Get.put(PurchaseOrderControllerNew());
      }),
    ),
    // 销售单 - 新框架
    GetPage(
      name: '/sale-order/create-new',
      page: () => const SaleOrderCreateViewNew(),
      binding: BindingsBuilder(() {
        Get.put(SaleOrderControllerNew());
      }),
    ),
    // 调拨单 - 新框架
    GetPage(
      name: '/transfer/create-new',
      page: () => const TransferCreateViewNew(),
      binding: BindingsBuilder(() {
        Get.put(TransferControllerNew());
      }),
    ),
    // 客户管理 - 新框架
    GetPage(
      name: '/customer/list-new',
      page: () => const CustomerListViewNew(),
      binding: BindingsBuilder(() {
        Get.put(CustomerControllerNew());
      }),
    ),
    GetPage(
      name: '/customer/form-new',
      page: () => const CustomerFormViewNew(),
      binding: BindingsBuilder(() {
        Get.put(CustomerFormController());
      }),
    ),
    // ============================================================
  ];
}
