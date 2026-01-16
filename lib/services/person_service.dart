import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:mosa/models/person.dart';

class PersonService {
  static Future<List<Person>> loadPersons() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/persons.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Person.fromJson(e)).toList();
    } catch (e) {
      log('Error loading persons: $e');
      return [];
    }
  }
}
