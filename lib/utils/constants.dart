import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConstants{
  static const String typeIncome = 'income';
  static const String typeOutCome = 'outcome';

  static const Map<String, IconData> incomeCategories = {
    'Lương': Icons.attach_money,
    'Thưởng': Icons.card_giftcard,
    'Tiền lãi': Icons.monetization_on,
    'Quà tặng': Icons.card_giftcard,
    'Đầu tư': Icons.trending_up,
    'Khác': Icons.money,
  };

  static const Map<String, IconData> outcomeCategories = {
    'Ăn uống': Icons.restaurant,
    'Mua sắm': Icons.shopping_cart,
    'Giải trí': Icons.movie,
    'Di chuyển': Icons.directions_car,
    'Hóa đơn': Icons.receipt,
    'Sức khỏe': Icons.health_and_safety,
    'Giáo dục': Icons.school,
    'Du lịch': Icons.flight,
    'Nhà cửa': Icons.home,
    'Cà phê': Icons.local_cafe,
    'Thuê xe': Icons.directions_car_filled,
    'Xăng xe': Icons.local_gas_station,
    'Bảo hiểm': Icons.security,
    'Thuế': Icons.account_balance,
    'Khác': Icons.more_horiz,
  };

  static const Color incomeColor = Color(0xFF4CAF50); // Màu xanh lá cho thu nhập
  static const Color outcomeColor = Color(0xFFF44336); // Màu đỏ cho chi tiêu

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
  static const int dbVersion = 1;
  static const String tableTransactions = 'transaction';
}