import 'package:get/get.dart';
import '../../../app/modules/customer/controllers/customer_controller_new.dart';
import '../../../app/modules/customer/controllers/customer_form_controller.dart';
import '../../../app/modules/supplier/controllers/supplier_controller_new.dart';
import '../../../app/modules/warehouse/controllers/warehouse_controller_new.dart';

/// 资料类页面绑定 - 新框架

/// 客户管理绑定
class CustomerBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerControllerNew>(
      () => CustomerControllerNew(),
      fenix: true,
    );
    Get.lazyPut<CustomerFormController>(
      () => CustomerFormController(),
      fenix: true,
    );
  }
}

/// 供应商管理绑定
class SupplierBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierControllerNew>(
      () => SupplierControllerNew(),
      fenix: true,
    );
    // SupplierFormController 可以在需要时创建
  }
}

/// 仓库管理绑定
class WarehouseBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarehouseControllerNew>(
      () => WarehouseControllerNew(),
      fenix: true,
    );
  }
}
