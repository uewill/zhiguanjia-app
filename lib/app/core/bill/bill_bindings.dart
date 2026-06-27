import 'package:get/get.dart';
import '../../../app/modules/purchase_order/controllers/purchase_order_controller_new.dart';
import '../../../app/modules/sale_order/controllers/sale_order_controller_new.dart';
import '../../../app/modules/transfer/controllers/transfer_controller_new.dart';

/// 单据类页面绑定 - 新框架
class PurchaseOrderBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseOrderControllerNew>(
      () => PurchaseOrderControllerNew(),
      fenix: true,
    );
  }
}

class SaleOrderBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleOrderControllerNew>(
      () => SaleOrderControllerNew(),
      fenix: true,
    );
  }
}

class TransferOrderBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferControllerNew>(
      () => TransferControllerNew(),
      fenix: true,
    );
  }
}
