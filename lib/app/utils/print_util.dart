import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// Print utility class - Simplified version
class PrintUtil {
  static const MethodChannel _channel = MethodChannel('printing');

  static void _showToast(BuildContext context, String message) {
    TDToast.showText(message, context: context);
  }

  /// Print order
  static Future<void> printOrder({
    required BuildContext context,
    required String orderNo,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required DateTime orderDate,
  }) async {
    try {
      final orderData = {
        'orderNo': orderNo,
        'customerName': customerName,
        'items': items,
        'totalAmount': totalAmount,
        'orderDate': orderDate.toIso8601String(),
      };

      // Try to use native printing
      try {
        await _channel.invokeMethod('printOrder', orderData);
      } catch (e) {
        // Fallback: Show print preview dialog
        _showToast(context, 'Print preview: Order $orderNo');
      }
    } catch (e) {
      _showToast(context, 'Print failed: $e');
    }
  }

  /// Print inventory report
  static Future<void> printInventoryReport({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> items,
    required DateTime reportDate,
  }) async {
    _showToast(context, 'Print inventory report: $title');
  }

  /// Print financial report
  static Future<void> printFinanceReport({
    required BuildContext context,
    required String period,
    required double income,
    required double expense,
    required double profit,
  }) async {
    _showToast(context, 'Print finance report: $period');
  }

  /// Share order as text
  static Future<void> shareOrderText({
    required String orderNo,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Order: $orderNo');
    buffer.writeln('Customer: $customerName');
    buffer.writeln('');
    buffer.writeln('Items:');
    for (var item in items) {
      buffer.writeln('  ${item['name']} x${item['qty']} @ ${item['price']}');
    }
    buffer.writeln('');
    buffer.writeln('Total: $totalAmount');

    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  /// Generate PDF (placeholder)
  static Future<String?> generateOrderPdf({
    required String orderNo,
    required Map<String, dynamic> orderData,
  }) async {
    return null;
  }

  /// Bluetooth print check
  static Future<bool> checkBluetoothPrinter() async {
    return false;
  }

  /// Connect to bluetooth printer
  static Future<bool> connectBluetoothPrinter(String address) async {
    return false;
  }
}
