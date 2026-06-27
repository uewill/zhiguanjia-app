import 'package:get/get.dart';
import '../../../services/permission_service.dart';
import '../../../services/staff_service.dart';
import '../controllers/permission_controller.dart';

class PermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermissionService(Get.find()));
    Get.lazyPut(() => StaffService(Get.find()));
    Get.lazyPut(() => PermissionController());
  }
}
