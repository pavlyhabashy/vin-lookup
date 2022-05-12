import 'dart:convert';

import 'package:http/http.dart';

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
}
