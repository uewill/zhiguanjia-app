import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/api_service.dart';
import 'app/services/storage_service.dart';
import 'app/services/cache_service.dart';
import 'app/services/print_service.dart';
import 'app/services/barcode_print_service.dart';
import 'app/services/qiniu_service.dart';
import 'app/services/excel_service.dart';
import 'app/services/voice_service.dart';
import 'app/services/image_recognition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏颜色
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 锁定竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化服务
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => CacheService().init());
  await Get.putAsync(() => ApiService().init());  // 使用init()
  Get.put(PrintService());
  Get.put(BarcodePrintService());
  Get.put(QiniuService());
  Get.put(ExcelService());
  Get.put(VoiceService());
  Get.put(ImageRecognitionService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '智掌柜',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2FC27D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2FC27D),
          primary: const Color(0xFF2FC27D),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
