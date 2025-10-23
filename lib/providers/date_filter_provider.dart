import 'package:flutter/cupertino.dart';

class DateFilterProvider extends ChangeNotifier{
  String _selectedMonth = 'Tháng này';
  String get selectedMonth => _selectedMonth;

  void setMonth(String month){
    _selectedMonth = month;
    notifyListeners();
  }
}