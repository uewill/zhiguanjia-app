import 'package:get/get.dart';
import '../../../services/warning_service.dart';
import '../controllers/warning_controller.dart';

class WarningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WarningService(Get.find()));
    Get.lazyPut(() => WarningController());
  }
}
