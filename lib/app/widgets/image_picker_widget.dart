import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../services/qiniu_service.dart';

/// 图片选择组件 - 支持本地和七牛云上传
class ImagePickerWidget extends StatelessWidget {
  final List<String> images;
  final Function(List<String>) onChanged;
  final int maxCount;
  final String? title;
  
  const ImagePickerWidget({
    Key? key,
    required this.images,
    required this.onChanged,
    this.maxCount = 9,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TDText(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              TDText('${images.length}/$maxCount', style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...images.asMap().entries.map((entry) => _buildImageItem(entry.key, entry.value)),
            if (images.length < maxCount) _buildAddButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(int index, String url) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: url.startsWith('http')
                  ? NetworkImage(url) as ImageProvider
                  : FileImage(File(url)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E6EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF86909C), size: 28),
            SizedBox(height: 4),
            TDText('添加图片', style: TextStyle(fontSize: 12, color: Color(0xFF86909C))),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const TDText('选择图片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2FC27D)),
              title: const Text('从相册选择'),
              onTap: () {
                Get.back();
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2FC27D)),
              title: const Text('拍照'),
              onTap: () {
                Get.back();
                _takePhoto();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.link, color: Color(0xFF2FC27D)),
              title: const Text('输入网址'),
              onTap: () {
                Get.back();
                _showUrlInputDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    final newImages = List<String>.from(images);
    newImages.removeAt(index);
    onChanged(newImages);
  }

  Future<void> _pickFromGallery() async {
    TDToast.showLoading(context: Get.context!, text: '上传中...');
    try {
      final url = await ImagePickerUtil.pickAndUpload();
      if (url != null) {
        final newImages = List<String>.from(images)..add(url);
        onChanged(newImages);
      }
    } catch (e) {
      TDToast.showText('上传失败: $e', context: Get.context!);
    }
  }

  Future<void> _takePhoto() async {
    TDToast.showLoading(context: Get.context!, text: '上传中...');
    try {
      final url = await ImagePickerUtil.takePhotoAndUpload();
      if (url != null) {
        final newImages = List<String>.from(images)..add(url);
        onChanged(newImages);
      }
    } catch (e) {
      TDToast.showText('上传失败: $e', context: Get.context!);
    }
  }

  void _showUrlInputDialog() {
    final urlController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('输入图片网址'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && url.startsWith('http')) {
                final newImages = List<String>.from(images)..add(url);
                onChanged(newImages);
                Get.back();
              } else {
                TDToast.showText('请输入有效的网址', context: Get.context!);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
