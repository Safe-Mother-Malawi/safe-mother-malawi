import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/risk_record.dart';

class RiskService {
  static const _key = 'risk_records';

  Future<void> saveRecord(RiskRecord r) async {
    final prefs   = await SharedPreferences.getInstance();
    final records = await loadAll();
    records.add(r);
    final encoded = records.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, encoded);
  }

  Future<List<RiskRecord>> loadAll() async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_key) ?? [];
    return encoded
        .map((e) => RiskRecord.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<void> deleteAt(int index) async {
    final prefs   = await SharedPreferences.getInstance();
    final records = await loadAll();
    if (index < 0 || index >= records.length) return;
    records.removeAt(index);
    final encoded = records.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, encoded);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
