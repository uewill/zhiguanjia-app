import '../../../../app/core/data/index.dart';

/// 客户表单控制器
class CustomerFormController extends DataFormController {
  @override
  DataPageConfig get config => DataPageConfig.customer;

  @override
  void populateForm(Map<String, dynamic> data) {
    nameController.text = data['name'] ?? '';
    phoneController.text = data['phone'] ?? '';
    addressController.text = data['address'] ?? '';
    remarkController.text = data['remark'] ?? '';
  }

  @override
  Map<String, dynamic> collectFormData() => {
    'name': nameController.text.trim(),
    'phone': phoneController.text.trim(),
    'address': addressController.text.trim(),
    'remark': remarkController.text.trim(),
  };

  @override
  bool validateForm() {
    if (!super.validateForm()) return false;
    
    if (phoneController.text.trim().isNotEmpty) {
      final phone = phoneController.text.trim();
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
        Get.snackbar('提示', '请输入正确的手机号码');
        return false;
      }
    }
    return true;
  }
}