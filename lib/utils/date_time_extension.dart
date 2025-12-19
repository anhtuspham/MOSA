import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:mosa/utils/constants.dart';

extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day, 0, 0, 0);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  String get apiFormat => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  String get ddMMyyy => DateFormat('dd-MM-yyyy').format(this);

  String get yyyyMMdd => DateFormat('yyyy-MM-dd').format(this);

  String get MMyyy => DateFormat('MM-yyyy').format(this);

  String get hhMM => DateFormat('HH:mm').format(this);

  String get hhMMddMMyyyy => DateFormat('HH:mm dd/MM/yyyy').format(this);

  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  DateTime get endOfMonth {
    return DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
  }

  String get weekdayName {
    final List<String> weekdays = [
      AppConstants.sunday,
      AppConstants.monday,
      AppConstants.tuesday,
      AppConstants.wednesday,
      AppConstants.thursday,
      AppConstants.friday,
      AppConstants.saturday,
    ];
    return weekdays[weekday % 7];
  }

  String get weekdayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(year, month, day);
    final diffDays = today.difference(thisDate).inDays;

    switch (diffDays) {
      case -1:
        return AppConstants.tomorrow;
      case 0:
        return AppConstants.today;
      case 1:
        return AppConstants.yesterday;
      default:
        return weekdayName;
    }
  }

  DateTime get startOfPreviousMonth {
    if (month == 1) {
      return DateTime(year - 1, 12, 1);
    } else {
      return DateTime(year, month - 1, 1);
    }
  }

  DateTime get startOfWeek {
    return subtract(
      Duration(days: weekday - 1),
    ).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).copyWith(
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
      microsecond: 999,
    );
  }
}

DateTime getStartOfMonth(String input) {
  List<String> parts = input.split('-');
  int month = int.parse(parts[0]);
  int year = int.parse(parts[1]);
  return DateTime(year, month, 1, 0, 0, 0);
}

DateTime getEndOfMonth(String input) {
  List<String> parts = input.split('-');
  int month = int.parse(parts[0]);
  int year = int.parse(parts[1]);
  DateTime firstDayNextMonth = DateTime(year, month + 1, 1, 0, 0, 0);
  return firstDayNextMonth.subtract(const Duration(seconds: 1));
}

int getCurrentWeekNumber() {
  final now = DateTime.now();
  final firstDayOfYear = DateTime(now.year, 1, 1);
  final daysPassed = now.difference(firstDayOfYear).inDays;

  // ISO 8601: tuần bắt đầu từ Thứ Hai
  final weekNumber = ((daysPassed + firstDayOfYear.weekday) / 7).ceil();
  return weekNumber;
}

int getCurrentQuarter() {
  final currentMonth = DateTime.now().month;
  return ((currentMonth - 1) ~/ 3) + 1;
}

String formatDateFromInt(int yyyyMMdd) {
  // Chuyển số thành chuỗi
  String dateStr = yyyyMMdd.toString();

  // Kiểm tra độ dài chuỗi
  if (dateStr.length != 8) {
    throw FormatException('Định dạng ngày không hợp lệ, phải là yyyyMMdd');
  }

  // Tách thành các phần năm, tháng, ngày
  String year = dateStr.substring(0, 4);
  String month = dateStr.substring(4, 6);
  String day = dateStr.substring(6, 8);

  // Kết hợp với dấu gạch ngang
  return '$year-$month-$day';
}

String formatTimestampToDateTime(int timestamp) {
  try {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  } catch (e) {
    return "";
  }
}

int formatDateInt() {
  return int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
}

int formatDateIntFromDate(DateTime date) {
  return int.parse(DateFormat('yyyyMMdd').format(date));
}

String formatTimestampToString(int yyyyMMdd) {
  try {
    final dateStr = yyyyMMdd.toString();
    if (dateStr.length != 8) return "";

    final date = DateTime(
      int.parse(dateStr.substring(0, 4)), // Năm
      int.parse(dateStr.substring(4, 6)), // Tháng
      int.parse(dateStr.substring(6, 8)), // Ngày
    );

    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return ""; // Xử lý lỗi
  }
}

int getWeekNumber(DateTime date) {
  final dayOfYear = int.parse(DateFormat("D").format(date));
  final weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
  return weekNumber;
}

DateTime getWeekStart(DateTime date) {
  final daysFromMonday = date.weekday - 1;
  return date.subtract(Duration(days: daysFromMonday));
}

String getWeekDateRange(DateTime date) {
  final startOfWeek = getWeekStart(date);
  final endOfWeek = startOfWeek.add(Duration(days: 6));
  return '${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}';
}

String convertDateTimeToString(DateTime time) {
  return DateFormat('dd/MM/yyyy').format(time);
}
