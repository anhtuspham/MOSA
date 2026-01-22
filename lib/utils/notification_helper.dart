import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/transaction.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _debtChannel =
      AndroidNotificationChannel(
    'debt_reminders',
    'Debt Reminders',
    description: 'Notifications for debt due dates and payments',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _transactionChannel =
      AndroidNotificationChannel(
    'transaction_alerts',
    'Transaction Alerts',
    description: 'Notifications for transactions and budgets',
    importance: Importance.defaultImportance,
  );

  static Future<void> initialize() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_debtChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_transactionChannel);
  }

  static Future<void> scheduleDebtReminder({
    required int debtId,
    required String personName,
    required double amount,
    required DateTime dueDate,
    required DebtType debtType,
  }) async {
    final isLent = debtType == DebtType.lent;
    final title = isLent
        ? 'Nhắc nhở thu nợ'
        : 'Nhắc nhở trả nợ';
    final body = isLent
        ? 'Khoản cho vay $personName sắp đến hạn: ${amount.toStringAsFixed(0)} VND'
        : 'Khoản vay từ $personName sắp đến hạn: ${amount.toStringAsFixed(0)} VND';

    await _notifications.zonedSchedule(
      debtId,
      title,
      body,
      _convertToTZDateTime(dueDate.subtract(const Duration(days: 1))),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _debtChannel.id,
          _debtChannel.name,
          channelDescription: _debtChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'debt_$debtId',
    );
  }

  static Future<void> notifyOverdueDebt({
    required int debtId,
    required String personName,
    required double amount,
    required DebtType debtType,
  }) async {
    final isLent = debtType == DebtType.lent;
    final title = isLent ? 'Khoản cho vay quá hạn' : 'Khoản vay quá hạn';
    final body = isLent
        ? '$personName chưa trả nợ: ${amount.toStringAsFixed(0)} VND'
        : 'Bạn chưa trả nợ cho $personName: ${amount.toStringAsFixed(0)} VND';

    await _notifications.show(
      debtId + 10000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _debtChannel.id,
          _debtChannel.name,
          channelDescription: _debtChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFFFF5252),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'debt_overdue_$debtId',
    );
  }

  static Future<void> notifyDebtPayment({
    required String personName,
    required double amount,
    required DebtType debtType,
  }) async {
    final isLent = debtType == DebtType.lent;
    final title = isLent ? 'Đã thu nợ' : 'Đã trả nợ';
    final body = isLent
        ? 'Đã thu ${amount.toStringAsFixed(0)} VND từ $personName'
        : 'Đã trả ${amount.toStringAsFixed(0)} VND cho $personName';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _debtChannel.id,
          _debtChannel.name,
          channelDescription: _debtChannel.description,
          importance: Importance.defaultImportance,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFF4CAF50),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> notifyBudgetWarning({
    required String categoryName,
    required double spent,
    required double budget,
  }) async {
    final percentage = (spent / budget * 100).toInt();
    await _notifications.show(
      categoryName.hashCode,
      'Cảnh báo ngân sách',
      'Đã chi $percentage% ngân sách $categoryName: ${spent.toStringAsFixed(0)}/${budget.toStringAsFixed(0)} VND',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _transactionChannel.id,
          _transactionChannel.name,
          channelDescription: _transactionChannel.description,
          importance: Importance.defaultImportance,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFFFFA726),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> cancelDebtReminder(int debtId) async {
    await _notifications.cancel(debtId);
    await _notifications.cancel(debtId + 10000);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    return tz.TZDateTime.from(dateTime, location);
  }

  // Schedule daily reminder at specific time (e.g., 8 PM every day)
  static Future<void> scheduleDailyReminder({
    required int notificationId,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.getLocation('Asia/Ho_Chi_Minh'));
    var scheduledDate = tz.TZDateTime(
      tz.getLocation('Asia/Ho_Chi_Minh'),
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If scheduled time is in the past today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _debtChannel.id,
          _debtChannel.name,
          channelDescription: _debtChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily!
    );
  }

  // Schedule notification for specific date and time
  static Future<void> scheduleNotificationAt({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    final tzScheduledDate = _convertToTZDateTime(scheduledDateTime);

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _debtChannel.id,
          _debtChannel.name,
          channelDescription: _debtChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Check and schedule all upcoming debt reminders
  static Future<void> scheduleAllDebtReminders(List<Debt> debts) async {
    for (final debt in debts) {
      if (debt.status != DebtStatus.paid && debt.dueDate != null) {
        // Schedule reminder at 8 PM on due date
        final reminderTime = DateTime(
          debt.dueDate!.year,
          debt.dueDate!.month,
          debt.dueDate!.day,
          20, // 8 PM
          0,
        );

        if (reminderTime.isAfter(DateTime.now())) {
          await scheduleNotificationAt(
            notificationId: debt.id ?? 0,
            title: debt.type == DebtType.lent ? 'Thu nợ hôm nay' : 'Trả nợ hôm nay',
            body: 'Nhắc nhở: ${debt.description} - ${debt.amount.toStringAsFixed(0)} VND',
            scheduledDateTime: reminderTime,
            payload: 'debt_${debt.id}',
          );
        }

        // Also schedule 1 day before at 8 PM
        final oneDayBefore = reminderTime.subtract(const Duration(days: 1));
        if (oneDayBefore.isAfter(DateTime.now())) {
          await scheduleNotificationAt(
            notificationId: (debt.id ?? 0) + 100000,
            title: debt.type == DebtType.lent ? 'Thu nợ ngày mai' : 'Trả nợ ngày mai',
            body: 'Nhắc nhở: ${debt.description} - ${debt.amount.toStringAsFixed(0)} VND',
            scheduledDateTime: oneDayBefore,
            payload: 'debt_${debt.id}',
          );
        }
      }
    }
  }

  // Get all pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}