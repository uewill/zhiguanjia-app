import 'package:get/get.dart';
import '../controllers/finance_report_controller.dart';

class FinanceReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FinanceReportController());
  }
}
