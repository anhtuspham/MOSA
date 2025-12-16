import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:mosa/models/bank.dart';

class BankService {
  static Future<List<Bank>> loadBank() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/bank.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((e) => Bank.fromJson(e)).toList();
    } catch (e) {
      log('Error when loadBank: $e');
      return [];
    }
  }
}
