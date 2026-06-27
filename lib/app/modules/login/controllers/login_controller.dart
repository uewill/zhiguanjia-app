import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController(text: 'admin');
  final passwordController = TextEditingController(text: '123456');
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('提示', '请输入账号和密码');
      return;
    }

    isLoading.value = true;
    try {
      final response = await Get.find<ApiService>().post(
        '/auth/login',
        data: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      );

      if (response.data['code'] == 200) {
        final token = response.data['data']['accessToken'];
        await StorageService.to.setToken(token);
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar('登录失败', response.data['message'] ?? '登录失败');
      }
    } catch (e) {
      Get.snackbar('错误', '网络请求失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
