import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConstants{
  static const String typeIncome = 'income';
  static const String typeOutCome = 'outcome';

  static const double scaleTextFactor = 1.5;

  static const Color incomeColor = Color(0xFF4CAF50); // Màu xanh lá cho thu nhập
  static const Color expenseColor = Color(0xFFF44336); // Màu đỏ cho chi tiêu

  static const Map<String, Color> categoryColors = {
    'Lương': Colors.green,
    'Thưởng': Colors.blue,
    'Tiền lãi': Colors.purple,
    'Quà tặng': Colors.pink,
    'Đầu tư': Colors.teal,
    'Khác': Colors.grey,
    'Ăn uống': Colors.orange,
    'Mua sắm': Colors.red,
    'Giải trí': Colors.cyan,
    'Di chuyển': Colors.indigo,
    'Hóa đơn': Colors.brown,
    'Sức khỏe': Colors.lightGreen,
    'Giáo dục': Colors.amber,
    'Du lịch': Colors.lightBlue,
    'Nhà cửa': Colors.deepOrange,
    'Cà phê': Colors.lime,
    'Thuê xe': Colors.deepPurple,
    'Xăng xe': Colors.yellow,
    'Bảo hiểm': Colors.blueGrey,
    'Thuế': Colors.tealAccent,
  };

  static const String dbName = 'finance_tracker.db';
  static const int dbVersion = 4;
  static const String tableTransactions = 'transactions';
  static const String tableWallets = 'wallets';

  static const String sunday = 'Chủ nhật';
  static const String monday = 'Thứ 2';
  static const String tuesday = 'Thứ 3';
  static const String wednesday = 'Thứ 4';
  static const String thursday = 'Thứ 5';
  static const String friday = 'Thứ 6';
  static const String saturday = 'Thứ 7';
  static const String yesterday = 'Hôm qua';
  static const String today = 'Hôm nay';
  static const String tomorrow = 'Ngày mai';
  static const String thisWeek = 'Tuần này';
  static const String thisMonth = 'Tháng này';
  static const String thisQuarter = 'Quý này';
  static const String thisYear = 'Năm này';
}