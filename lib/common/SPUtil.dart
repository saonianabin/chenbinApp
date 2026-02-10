import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  static SharedPreferences? _prefs;

  // 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 保存数据
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  // 获取数据
  static String getString(String key, [String defValue = '']) {
    return _prefs?.getString(key) ?? defValue;
  }

  static int getInt(String key, [int defValue = 0]) {
    return _prefs?.getInt(key) ?? defValue;
  }

  static double getDouble(String key, [double defValue = 0.0]) {
    return _prefs?.getDouble(key) ?? defValue;
  }

  static bool getBool(String key, [bool defValue = false]) {
    return _prefs?.getBool(key) ?? defValue;
  }

  static List<String> getStringList(String key, [List<String> defValue = const []]) {
    return _prefs?.getStringList(key) ?? defValue;
  }

  // 删除数据
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // 清空所有数据
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // 检查key是否存在
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // 获取所有key
  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // 存储对象
  static Future<bool> setObject(String key, Object value) async {
    String json = jsonEncode(value);
    return await setString(key, json);
  }

  // 获取对象
  static T? getObject<T>(String key, T Function(Map<String, dynamic> map) fromJson) {
    String? json = _prefs?.getString(key);
    if (json == null || json.isEmpty) return null;
    try {
      Map<String, dynamic> map = jsonDecode(json);
      return fromJson(map);
    } catch (e) {
      print('SPUtil getObject error: $e');
      return null;
    }
  }

  // 获取对象列表
  static List<T> getObjectList<T>(String key, T Function(Map<String, dynamic> map) fromJson) {
    String? json = _prefs?.getString(key);
    if (json == null || json.isEmpty) return [];
    try {
      List<dynamic> list = jsonDecode(json);
      return list.map((item) => fromJson(item)).toList();
    } catch (e) {
      print('SPUtil getObjectList error: $e');
      return [];
    }
  }
}