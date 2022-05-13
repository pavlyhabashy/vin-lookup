import 'dart:convert';

import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:http/http.dart';
import 'package:vin_lookup/classes/user.dart';

class Authentication {
  Future<bool> autoLogin() async {
    String? userData = await FlutterKeychain.get(key: "user");
    if (userData != null) {
      return true;
    }

    return false;
  }

  Future<User> getStoredUser() async {
    String? userData = await FlutterKeychain.get(key: "user");
    if (userData != null) {
      var json = jsonDecode(userData);
      return User.fromJson(json, json["password"]);
    }
    throw Exception('No user found.');
  }

  Future<Response> getUser(String id, String auth) {
    return get(
      Uri.parse('https://staff.dev.fixdapp.com/api/v2/users/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $auth',
        'Content-Type': 'application/json;distance=mi;currency=USD',
        'X-Endpoint-Version': '2019-06-20',
        'X-Verbose-Response': 'true',
        'Accept-Language': 'en-US',
        'X-Key-Inflection': 'snake',
      },
    );
  }

  Future<Response> login(String email, String password) {
    return post(
      Uri.parse('https://staff.dev.fixdapp.com/api/v2/session'),
      headers: <String, String>{
        'Content-Type': 'application/json;distance=mi;currency=USD',
        'X-Endpoint-Version': '2019-06-20',
        'X-Verbose-Response': 'true',
        'Accept-Language': 'en-US',
        'X-Key-Inflection': 'snake',
      },
      body: jsonEncode(<String, Object>{
        "session": {
          "email": email,
          "password": password,
        }
      }),
    );
  }

  saveUser(User user) async {
    await FlutterKeychain.put(
        key: "user", value: jsonEncode(user.toJson()).toString());
  }
}
