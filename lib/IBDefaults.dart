
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class IBDefaults {

  static const ID_USER = "id_user";
  static const IDS_GROUPS = "ids_groups";
  static const TIMESTAMP_LAST_ACCESSED_GROUPS = "timestamp_last_accessed_groups";
  static const TOKEN = "token";

  // GET
  // ..
  // ..
  static Future<String> getIdUser() async {
    var completer = new Completer<String>();
    var prefs = await SharedPreferences.getInstance();
    completer.complete(prefs.getString(ID_USER));
    return completer.future;
  }

  static Future<String> getToken() async {
    var completer = new Completer<String>();
    var prefs = await SharedPreferences.getInstance();
    completer.complete(prefs.getString(TOKEN));
    return completer.future;
  }

  // SET
  // ..
  // ..
  static Future setIdUser(String id) async {
    var completer = new Completer();
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(ID_USER, id);
    completer.complete();
    return completer.future;
  }

  static Future setToken(String token) async {
    var completer = new Completer();
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(TOKEN, token);
    completer.complete();
    return completer.future;
  }
}