import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据备份'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.isCreating.value ? null : controller.createBackup,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 自动备份设置
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '自动备份设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => SwitchListTile(
                    title: const Text('启用自动备份'),
                    subtitle: const Text('按设定频率自动备份数据'),
                    value: controller.autoBackupEnabled.value,
                    onChanged: controller.setAutoBackup,
                  )),
                  Obx(() => controller.autoBackupEnabled.value
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<String>(
                            value: controller.backupFrequency.value,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'daily', child: Text('每天')),
                              DropdownMenuItem(value: 'weekly', child: Text('每周')),
                              DropdownMenuItem(value: 'monthly', child: Text('每月')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.setBackupFrequency(value);
                              }
                            },
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),

            // 手动备份按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isCreating.value ? null : controller.createBackup,
                icon: controller.isCreating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup),
                label: Text(controller.isCreating.value ? '正在备份...' : '立即备份'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )),
            ),

            const SizedBox(height: 16),

            // 备份列表
            Expanded(
              child: controller.backupList.isEmpty
                  ? const Center(child: Text('暂无备份记录'))
                  : ListView.builder(
                      itemCount: controller.backupList.length,
                      itemBuilder: (context, index) {
                        final backup = controller.backupList[index];
                        return _buildBackupItem(backup);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBackupItem(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.backup),
        ),
        title: Text(backup.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(backup.createTime.toString().substring(0, 19)),
            Text('大小: ${backup.formattedSize}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'restore', child: Text('恢复数据')),
            const PopupMenuItem(value: 'export', child: Text('导出')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'restore':
                controller.restoreBackup(backup);
                break;
              case 'export':
                controller.exportBackup(backup);
                break;
              case 'delete':
                controller.deleteBackup(backup);
                break;
            }
          },
        ),
      ),
    );
  }
}
