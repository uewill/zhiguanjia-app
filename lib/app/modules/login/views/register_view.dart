import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final shopNameController = TextEditingController();
  final agreeTerms = false.obs;
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
              const TDText('注册账号', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2FC27D))),
              const SizedBox(height: 8),
              const TDText('开启您的智能进销存之旅', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                controller: passwordController,
                leftLabel: '设置密码',
                hintText: '请设置登录密码',
                leftIcon: const TDText('🔒', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TDInput(
                controller: confirmPasswordController,
                leftLabel: '确认密码',
                hintText: '请再次输入密码',
                leftIcon: const TDText('🔒', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TDInput(
                controller: shopNameController,
                leftLabel: '店铺名称',
                hintText: '请输入店铺名称（选填）',
                leftIcon: const TDText('🏪', style: TextStyle(fontSize: 20)),
                backgroundColor: const Color(0xFFF5F5F5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Obx(() => Checkbox(
                    value: agreeTerms.value,
                    onChanged: (v) => agreeTerms.value = v ?? false,
                    activeColor: const Color(0xFF2FC27D),
                  )),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => agreeTerms.value = !agreeTerms.value,
                      child: const TDText(
                        '我已阅读并同意《用户协议》和《隐私政策》',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TDButton(
                text: '注册',
                theme: TDButtonTheme.primary,
                size: TDButtonSize.large,
                isBlock: true,
                onTap: _register,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TDText('已有账号?', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const TDText('立即登录', style: TextStyle(color: Color(0xFF2FC27D))),
                  ),
                ],
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

  void _register() {
    if (phoneController.text.isEmpty) {
      TDToast.showText('请输入手机号', context: context);
      return;
    }
    if (codeController.text.isEmpty) {
      TDToast.showText('请输入验证码', context: context);
      return;
    }
    if (passwordController.text.isEmpty) {
      TDToast.showText('请设置密码', context: context);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      TDToast.showText('两次密码输入不一致', context: context);
      return;
    }
    if (!agreeTerms.value) {
      TDToast.showText('请同意用户协议', context: context);
      return;
    }
    TDToast.showText('注册成功', context: context);
    Get.back();
  }
}
