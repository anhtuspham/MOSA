import 'package:flutter/material.dart';
import 'package:mosa/providers/date_filter_provider.dart';

class DateRangeUtils {
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTimeRange<DateTime> getRange(DateRangeFilter filter, [DateTime? now]) {
    final currentDate = now ?? DateTime.now();
    switch (filter) {
      case DateRangeFilter.week:
        final monday = getMondayOfWeek(currentDate);
        return DateTimeRange(
          start: DateTime(monday.year, monday.month, monday.day),
          end: DateTime(currentDate.year, currentDate.month, currentDate.day),
        );
      case DateRangeFilter.month:
        return DateTimeRange(
          start: DateTime(currentDate.year, currentDate.month, 1),
          end: DateTime(currentDate.year, currentDate.month + 1, 1).subtract(Duration(seconds: 1)),
        );
      case DateRangeFilter.quarter:
        final quarter = (currentDate.month - 1) ~/ 3;
        return DateTimeRange(
          start: DateTime(currentDate.year, quarter * 3 + 1, 1),
          end: DateTime(currentDate.year, quarter * 3 + 4).subtract(Duration(seconds: 1)),
        );
      case DateRangeFilter.year:
        return DateTimeRange(
          start: DateTime(currentDate.year, 1, 1),
          end: DateTime(currentDate.year + 1, 1, 1).subtract(Duration(seconds: 1)),
        );
    }
  }

  static List<T> filterByDateRange<T>(List<T> items, DateTime start, DateTime end, DateTime Function(T) dateGetter) {
    return items.where((item) {
      final date = dateGetter(item);
      return date.isAfter(start) && date.isBefore(end);
    }).toList();
  }
}
