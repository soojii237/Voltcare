// ignore_for_file: strict_top_level_inference

import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<SharedPreferences> get _instance async =>
      _pref ??= await SharedPreferences.getInstance();
  static SharedPreferences? _pref;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _pref = await _instance;
    debugPrint("SHARED PREFERENCE INIT");
    return _pref!;
  }

  static Future<bool> save(
      {required String key, required dynamic value}) async {
    if (_pref == null) await init();
    switch (value.runtimeType) {
      case const (String):
        return _pref!.setString(key, value);
      case const (bool):
        return _pref!.setBool(key, value);
      case const (int):
        return _pref!.setInt(key, value);
      case const (double):
      
        return _pref!.setDouble(key, value);
      default:
        return _pref!.setString(key, jsonEncode(value));
    }
  }



 
  static void clear() {
    init();
    _pref?.clear();
  }

  static Future<bool> remove({required String key}) async {
    if (_pref == null) await init();
    return _pref!.remove(key);
  }
  static Future<int?>? getint(key) async {
    await init();
    int? value = _pref!.getInt(key);
    return value;
  }
  static Future<String?>? getstring(key) async {
    await init();
    String? value = _pref!.getString(key);
    return value;
  }
  static Future<bool> getbool(key) async {
    await init();
    bool? value = _pref!.getBool(key);
    return value??false;
  }

  
}
