import 'package:get/get.dart';
import '../../../services/workflow_service.dart';
import '../controllers/workflow_controller.dart';

class WorkflowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WorkflowService(Get.find()));
    Get.lazyPut(() => WorkflowController());
  }
}
