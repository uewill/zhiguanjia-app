import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 数据备份管理器
class BackupController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isRestoring = false.obs;
  final RxString lastBackupTime = ''.obs;
  final RxList<BackupInfo> backupList = <BackupInfo>[].obs;
  
  // 自动备份设置
  final RxBool autoBackupEnabled = false.obs;
  final RxString backupFrequency = 'daily'.obs; // daily, weekly, monthly

  @override
  void onInit() {
    super.onInit();
    loadBackupHistory();
    _loadSettings();
  }

  /// 加载备份历史
  Future<void> loadBackupHistory() async {
    isLoading.value = true;
    try {
      // 模拟数据
      await Future.delayed(const Duration(milliseconds: 500));
      backupList.value = [
        BackupInfo(
          id: '1',
          fileName: 'backup_20240115_120000.zip',
          size: 2457600,
          createTime: DateTime(2024, 1, 15, 12, 0),
        ),
        BackupInfo(
          id: '2',
          fileName: 'backup_20240114_080000.zip',
          size: 1892000,
          createTime: DateTime(2024, 1, 14, 8, 0),
        ),
      ];
      if (backupList.isNotEmpty) {
        lastBackupTime.value = backupList.first.createTime.toString().substring(0, 16);
      }
    } catch (e) {
      _showToast('加载备份列表失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  /// 加载设置
  void _loadSettings() {
    // TODO: 从local storage加载设置
    autoBackupEnabled.value = false;
    backupFrequency.value = 'daily';
  }

  /// 创建备份
  Future<void> createBackup() async {
    if (isCreating.value) return;
    
    isCreating.value = true;
    try {
      // 模拟备份过程
      await Future.delayed(const Duration(seconds: 2));
      
      final newBackup = BackupInfo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: 'backup_${_formatDateTime(DateTime.now())}.zip',
        size: 2500000 + (backupList.length * 100000),
        createTime: DateTime.now(),
      );
      
      backupList.insert(0, newBackup);
      lastBackupTime.value = newBackup.createTime.toString().substring(0, 16);
      
      _showToast('备份创建成功');
    } catch (e) {
      _showToast('备份失败: $e');
    } finally {
      isCreating.value = false;
    }
  }

  /// 恢复备份
  Future<void> restoreBackup(BackupInfo backup) async {
    if (isRestoring.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认恢复'),
        content: Text('恢复备份将覆盖当前数据：\n${backup.fileName}\n\n确定继续？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('恢复', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isRestoring.value = true;
    try {
      // 模拟恢复过程
      await Future.delayed(const Duration(seconds: 2));
      _showToast('恢复完成');
    } catch (e) {
      _showToast('恢复失败: $e');
    } finally {
      isRestoring.value = false;
    }
  }

  /// 删除备份
  Future<void> deleteBackup(BackupInfo backup) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('删除后无法恢复：\n${backup.fileName}'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      backupList.removeWhere((b) => b.id == backup.id);
      _showToast('删除成功');
    }
  }

  /// 导出备份
  Future<void> exportBackup(BackupInfo backup) async {
    _showToast('导出功能开发中...');
  }

  /// 导入备份
  Future<void> importBackup() async {
    _showToast('导入功能开发中...');
  }

  /// 设置自动备份
  void setAutoBackup(bool value) {
    autoBackupEnabled.value = value;
    _saveSettings();
  }

  /// 设置备份频率
  void setBackupFrequency(String value) {
    backupFrequency.value = value;
    _saveSettings();
  }

  /// 保存设置
  void _saveSettings() {
    // TODO: 保存到local storage
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}${_pad(dt.month)}${_pad(dt.day)}_${_pad(dt.hour)}${_pad(dt.minute)}${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

/// 备份信息模型
class BackupInfo {
  final String id;
  final String fileName;
  final int size; // bytes
  final DateTime createTime;

  BackupInfo({
    required this.id,
    required this.fileName,
    required this.size,
    required this.createTime,
  });

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}