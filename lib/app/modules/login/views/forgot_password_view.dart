import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isCodeSending = false.obs;
  final countdown = 0.obs;

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
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back, size: 24),
              ),
              const SizedBox(height: 32),
              const TDText('忘记密码', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2FC27D))),
              const SizedBox(height: 8),
              const TDText('请验证手机号后重置密码', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 48),
              TDInput(
                controller: phoneController,
                leftLabel: '手机号',
                hintText: '请输入手机号',
                leftIcon: const TDText('📱', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
              ),
              const SizedBox(height: 16),
              TDInput(
                controller: codeController,
                leftLabel: '验证码',
                hintText: '请输入验证码',
                leftIcon: const TDText('🔢', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
                rightWidget: Obx(() => GestureDetector(
                  onTap: countdown.value > 0 ? null : _sendCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: countdown.value > 0 ? Colors.grey : const Color(0xFF2FC27D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TDText(
                      countdown.value > 0 ? '${countdown.value}s' : '获取验证码',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TDInput(
                controller: newPasswordController,
                leftLabel: '新密码',
                hintText: '请输入新密码',
                leftIcon: const TDText('🔒', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TDInput(
                controller: confirmPasswordController,
                leftLabel: '确认密码',
                hintText: '请再次输入新密码',
                leftIcon: const TDText('🔒', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
                obscureText: true,
              ),
              const SizedBox(height: 48),
              TDButton(
                text: '重置密码',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                isBlock: true,
                onTap: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendCode() {
    if (phoneController.text.isEmpty) {
      TDToast.showText('请输入手机号', context: context);
      return;
    }
    countdown.value = 60;
    TDToast.showText('验证码已发送', context: context);
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      countdown.value--;
      return countdown.value > 0;
    });
  }

  void _resetPassword() {
    if (phoneController.text.isEmpty) {
      TDToast.showText('请输入手机号', context: context);
      return;
    }
    if (codeController.text.isEmpty) {
      TDToast.showText('请输入验证码', context: context);
      return;
    }
    if (newPasswordController.text.isEmpty) {
      TDToast.showText('请输入新密码', context: context);
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      TDToast.showText('两次密码输入不一致', context: context);
      return;
    }
    TDToast.showText('密码重置成功', context: context);
    Get.back();
  }
}
