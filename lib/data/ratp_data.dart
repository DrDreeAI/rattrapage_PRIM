import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ligne.dart';

Future<List<Ligne>> loadRatpData() async {
  final String jsonString = await rootBundle.loadString('assets/ratp_data.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Ligne.fromJson(json)).toList();
}
