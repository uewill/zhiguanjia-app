import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/workflow_model.dart';
import '../../../services/workflow_service.dart';

class WorkflowController extends GetxController {
  final WorkflowService _workflowService = Get.find<WorkflowService>();

  // 状态历史
  final statusHistory = <StatusHistory>[].obs;
  final isLoading = false.obs;

  // 待审核列表
  final pendingApprovals = <dynamic>[].obs;

  // 操作原因
  final reasonController = TextEditingController();

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  // 加载状态历史
  Future<void> loadStatusHistory(int orderId, String orderType) async {
    isLoading.value = true;
    try {
      statusHistory.value = await _workflowService.getStatusHistory(orderId, orderType);
    } finally {
      isLoading.value = false;
    }
  }

  // 加载待审核列表
  Future<void> loadPendingApprovals(String role) async {
    isLoading.value = true;
    try {
      pendingApprovals.value = await _workflowService.getPendingApprovals(role);
    } finally {
      isLoading.value = false;
    }
  }

  // 执行状态流转
  Future<void> transitionStatus({
    required int orderId,
    required String orderType,
    required int fromStatus,
    required int toStatus,
    String? actionName,
  }) async {
    // 检查是否需要填写原因
    final rule = StatusTransition.allRules.firstWhereOrNull(
      (r) => r.fromStatus == fromStatus && r.toStatus == toStatus,
    );

    String? reason;
    if (rule?.requireReason == true) {
      reason = await _showReasonDialog(actionName ?? '操作');
      if (reason == null) return; // 用户取消
    }

    final success = await _workflowService.transitionStatus(
      orderId: orderId,
      orderType: orderType,
      fromStatus: fromStatus,
      toStatus: toStatus,
      reason: reason,
    );

    if (success) {
      _showToast('操作成功');
      loadStatusHistory(orderId, orderType);
    } else {
      _showToast('操作失败');
    }
  }

  // 审核单据
  Future<void> approveOrder({
    required int orderId,
    required String orderType,
    required bool approved,
  }) async {
    String? reason;
    if (!approved) {
      reason = await _showReasonDialog('驳回');
      if (reason == null) return;
    }

    final success = await _workflowService.approveOrder(
      orderId: orderId,
      orderType: orderType,
      approved: approved,
      reason: reason,
    );

    if (success) {
      _showToast(approved ? '审核通过' : '已驳回');
      loadPendingApprovals('manager');
    } else {
      _showToast('操作失败');
    }
  }

  // 获取可用操作
  List<StatusTransition> getAvailableActions(int currentStatus) {
    return StatusTransition.getAvailableActions(currentStatus);
  }

  // 显示原因输入对话框
  Future<String?> _showReasonDialog(String actionName) async {
    reasonController.clear();
    
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('请填写$actionName原因'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: '请输入原因...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      return reasonController.text;
    }
    return null;
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  // 查看状态历史
  void viewStatusHistory(int orderId, String orderType) {
    loadStatusHistory(orderId, orderType);
    Get.toNamed('/workflow/history', arguments: {
      'orderId': orderId,
      'orderType': orderType,
    });
  }
}
