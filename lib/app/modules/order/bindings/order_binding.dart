import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../controllers/order_detail_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<OrderDetailController>(() => OrderDetailController());
  }
}
