import 'package:get/get.dart';
import '../../../services/staff_service.dart';
import '../controllers/staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffService(Get.find()));
    Get.lazyPut(() => StaffController());
  }
}
