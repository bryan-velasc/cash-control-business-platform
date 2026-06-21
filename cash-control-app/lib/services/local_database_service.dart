import 'package:hive/hive.dart';

class LocalDatabaseService {
  static const String boxName =
      "cash_control_local";

  static Box get box =>
      Hive.box(boxName);

  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    await box.put(
      key,
      value,
    );
  }

  static dynamic getData(
    String key,
  ) {
    return box.get(key);
  }

  static Future<void> deleteData(
    String key,
  ) async {
    await box.delete(key);
  }

  static Future<void> clearAll() async {
    await box.clear();
  }

  static bool exists(
    String key,
  ) {
    return box.containsKey(key);
  }
}