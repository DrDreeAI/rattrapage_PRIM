import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ligne.dart';

Future<List<Ligne>> loadRatpData() async {
  final String dataString = await rootBundle.loadString('assets/ratp_data.json');
  final List<dynamic> jsonData = json.decode(dataString);
  return jsonData.map((item) => Ligne.fromJson(item)).toList();
}
