import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/login_controller.dart';
import 'forgot_password_view.dart';
import 'register_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC27D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: TDText('🏪', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: TDText('智掌柜', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2FC27D)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: TDText('AI智能进销存管家', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
              const SizedBox(height: 48),
              TDInput(
                controller: controller.usernameController,
                leftLabel: '账号',
                hintText: '请输入账号',
                leftIcon: const TDText('👤', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
              ),
              const SizedBox(height: 16),
              Obx(() => TDInput(
                controller: controller.passwordController,
                leftLabel: '密码',
                hintText: '请输入密码',
                leftIcon: const TDText('🔒', style: TextStyle(fontSize: 20)),
                obscureText: !controller.isPasswordVisible.value,
                backgroundColor: const Color(0xFFF5F5F5),
                rightWidget: GestureDetector(
                  onTap: controller.togglePasswordVisibility,
                  child: TDText(controller.isPasswordVisible.value ? '👁️' : '👁️‍🗨️', style: TextStyle(fontSize: 20)),
                ),
              )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => const ForgotPasswordView()),
                  child: const TDText('忘记密码?', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => TDButton(
                text: controller.isLoading.value ? '登录中...' : '登录',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                isBlock: true,
                disabled: controller.isLoading.value,
                onTap: controller.login,
              )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 60, height: 1, color: Colors.grey.shade300),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TDText('或', style: TextStyle(color: Colors.grey)),
                  ),
                  Container(width: 60, height: 1, color: Colors.grey.shade300),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('📱', '手机号登录', () {}),
                  const SizedBox(width: 24),
                  _buildSocialButton('💚', '微信登录', () {}),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TDText('还没有账号?', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.to(() => const RegisterView()),
                    child: const TDText('立即注册', style: TextStyle(color: Color(0xFF2FC27D))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(child: TDText(emoji, style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 8),
          TDText(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
