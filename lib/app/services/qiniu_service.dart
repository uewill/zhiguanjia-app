import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio_lib;
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 七牛云上传服务
/// 使用直传方式上传文件到七牛云
class QiniuService extends GetxService {
  static QiniuService get to => Get.find<QiniuService>();
  
  final dio_lib.Dio _dio = dio_lib.Dio();
  
  // 七牛云配置 - 从后端获取上传凭证
  final String _uploadTokenUrl = '/api/qiniu/token';
  final String _domain = 'https://img.zhiguanjia.com'; // 替换为你的空间域名
  
  @override
  void onInit() {
    super.onInit();
    _dio.options.baseUrl = 'https://upload.qiniup.com';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }
  
  /// 上传文件到七牛云
  /// 
  /// [file] - 要上传的文件
  /// [key] - 文件存储路径，如不传则自动生成
  /// 返回上传后的文件URL
  Future<String?> uploadFile(File file, {String? key}) async {
    try {
      // 1. 从后端获取上传凭证
      final token = await _getUploadToken();
      if (token == null) {
        TDToast.showText('获取上传凭证失败', context: Get.context!);
        return null;
      }
      
      // 2. 生成文件key
      final fileKey = key ?? _generateKey(file.path);
      
      // 3. 构建表单数据
      final formData = dio_lib.FormData.fromMap({
        'token': token,
        'key': fileKey,
        'file': await dio_lib.MultipartFile.fromFile(file.path),
      });
      
      // 4. 上传到七牛云
      final response = await _dio.post('/', data: formData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final uploadedKey = data['key'] as String;
        final url = '$_domain/$uploadedKey';
        
        TDToast.showText('上传成功', context: Get.context!);
        return url;
      } else {
        TDToast.showText('上传失败: ${response.statusCode}', context: Get.context!);
        return null;
      }
    } on dio_lib.DioException catch (e) {
      TDToast.showText('上传失败: ${e.message}', context: Get.context!);
      return null;
    } catch (e) {
      TDToast.showText('上传失败: $e', context: Get.context!);
      return null;
    }
  }
  
  /// 上传字节数组到七牛云
  /// 
  /// [bytes] - 要上传的字节数据
  /// [fileName] - 文件名
  /// [key] - 文件存储路径
  Future<String?> uploadBytes(Uint8List bytes, String fileName, {String? key}) async {
    try {
      final token = await _getUploadToken();
      if (token == null) {
        TDToast.showText('获取上传凭证失败', context: Get.context!);
        return null;
      }
      
      final fileKey = key ?? _generateKey(fileName);
      
      final formData = dio_lib.FormData.fromMap({
        'token': token,
        'key': fileKey,
        'file': dio_lib.MultipartFile.fromBytes(bytes, filename: fileName),
      });
      
      final response = await _dio.post('/', data: formData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final uploadedKey = data['key'] as String;
        final url = '$_domain/$uploadedKey';
        
        TDToast.showText('上传成功', context: Get.context!);
        return url;
      } else {
        TDToast.showText('上传失败', context: Get.context!);
        return null;
      }
    } catch (e) {
      TDToast.showText('上传失败: $e', context: Get.context!);
      return null;
    }
  }
  
  /// 批量上传文件
  Future<List<String>> uploadFiles(List<File> files) async {
    final urls = <String>[];
    
    for (final file in files) {
      final url = await uploadFile(file);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }
  
  /// 从后端获取上传凭证
  Future<String?> _getUploadToken() async {
    try {
      // 调用后端API获取上传凭证
      // 后端使用七牛SecretKey生成签名的uploadToken
      // 示例响应: {"token": "xxx", "domain": "https://xxx.com"}
      
      // 注意：这里是示例，实际需要调用你的后端API
      // final response = await Get.find<ApiService>().get(_uploadTokenUrl);
      // return response.data['token'];
      
      // 临时返回null，等待后端实现
      TDToast.showText('请先配置七牛云上传凭证', context: Get.context!);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 生成文件存储key
  String _generateKey(String filePath) {
    final ext = filePath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 10000).toString().padLeft(4, '0');
    return 'products/$timestamp$random.$ext';
  }
  
  /// 删除七牛云上的文件
  /// 需要后端提供管理凭证才能删除
  Future<bool> deleteFile(String key) async {
    try {
      // 调用后端API删除文件
      // await Get.find<ApiService>().post('/api/qiniu/delete', data: {'key': key});
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取图片缩略图URL
  String getThumbnailUrl(String url, {int width = 200, int height = 200}) {
    // 七牛图片处理格式：https://xxx.com/key?imageView2/1/w/200/h/200
    return '$url?imageView2/1/w/$width/h/$height';
  }
  
  /// 获取图片预览URL（带水印）
  String getWatermarkedUrl(String url, String watermarkText) {
    // 七牛图片处理 - 添加文字水印
    final encodedText = base64UrlEncode(utf8.encode(watermarkText));
    return '$url?watermark/2/text/$encodedText/font/5b6u6L2v6ZuF6buR/fill/I0ZGRkZGRg==';
  }
}

/// 图片选择和上传工具类
class ImagePickerUtil {
  /// 选择图片并上传到七牛云
  static Future<String?> pickAndUpload() async {
    try {
      // 使用image_picker选择图片
      // final picker = ImagePicker();
      // final pickedFile = await picker.pickImage(
      //   source: ImageSource.gallery,
      //   maxWidth: 1024,
      //   maxHeight: 1024,
      //   imageQuality: 85,
      // );
      // 
      // if (pickedFile != null) {
      //   final file = File(pickedFile.path);
      //   return await QiniuService.to.uploadFile(file);
      // }
      
      TDToast.showText('请先安装 image_picker 插件', context: Get.context!);
      return null;
    } catch (e) {
      TDToast.showText('选择图片失败: $e', context: Get.context!);
      return null;
    }
  }
  
  /// 拍照并上传
  static Future<String?> takePhotoAndUpload() async {
    try {
      // final picker = ImagePicker();
      // final pickedFile = await picker.pickImage(
      //   source: ImageSource.camera,
      //   maxWidth: 1024,
      //   maxHeight: 1024,
      //   imageQuality: 85,
      // );
      // 
      // if (pickedFile != null) {
      //   final file = File(pickedFile.path);
      //   return await QiniuService.to.uploadFile(file);
      // }
      
      TDToast.showText('请先安装 image_picker 插件', context: Get.context!);
      return null;
    } catch (e) {
      TDToast.showText('拍照失败: $e', context: Get.context!);
      return null;
    }
  }
}
