/// 智掌柜单据组件库
/// 统一导出所有可复用组件

// 表头组件
export 'bill_header.dart' show
    BillHeader,
    BillHeaderField,
    BillHeaderFieldType,
    SimpleBillHeader,
    BillHeaderRow;

// 表尾组件
export 'bill_footer.dart' show
    BillFooter,
    BillFooterField,
    BillFooterFieldType,
    OrderBillFooter,
    SimpleBillFooter;

// 商品选择组件
export 'product_picker.dart' show
    ProductPicker,
    SelectedProduct,
    OnProductSelected,
    OnProductsSelected;

// 商品展示组件
export 'product_display.dart' show
    ProductDisplay,
    ProductDisplayMode,
    ProductList,
    ProductGrid;

// 旧组件（兼容保留）
export 'bill_bottom_bar.dart';
export 'partner_selector.dart';
export 'warehouse_selector.dart';
export 'product_selector.dart' show ProductSelector;
export 'product_info_card.dart';
export 'date_selector.dart';
export 'remark_card.dart';
export 'reusable_selectors.dart' hide ProductSelector;
export 'item_list.dart';
export 'form_fields/index.dart';
