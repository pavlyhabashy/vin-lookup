import 'dart:convert';

import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:http/http.dart';
import 'package:vin_lookup/classes/user.dart';

class Authentication {
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

  Future<bool> autoLogin() async {
    String? userData = await FlutterKeychain.get(key: "user");
    if (userData != null) {
      print(userData);
      User user = User.fromJson(jsonDecode(userData));
      print(user.authenticationToken);
      return true;
    }

    return false;
  }

  saveUser(User user) async {
    await FlutterKeychain.put(
        key: "user", value: jsonEncode(user.toJson()).toString());
  }
}
