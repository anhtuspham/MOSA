import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:mosa/models/wallets.dart';

class TypeWalletService{
  static Future<List<TypeWallet>> loadTypeWallets() async{
    try{
      final jsonString = await rootBundle.loadString('assets/data/type_wallets.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((e) => TypeWallet.fromJson(e)).toList();
    } catch(e){
      log('Error when loadTypeWallet: $e');
      return [];
    }
  }
}