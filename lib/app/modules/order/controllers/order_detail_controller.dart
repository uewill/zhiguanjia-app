import 'package:get/get.dart';
import '../../../data/models/order_model.dart';

class OrderDetailController extends GetxController {
  final order = Rxn<Order>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      order.value = Get.arguments as Order;
    }
  }
}
