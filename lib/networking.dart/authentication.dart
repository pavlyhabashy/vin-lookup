import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:http/http.dart';
import 'package:vin_lookup/classes/user.dart';
import 'package:vin_lookup/networking.dart/shared.dart';

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

  Future<User> pullUserAndReauthenticate(BuildContext context) async {
    // Get stored user from keychain
    User storedUser = await getStoredUser();

    // No internet connection, return saved user
    if (!(await checkConnection(context))) {
      return storedUser;
    }

    // GET user info
    Response response =
        await getUser(storedUser.id, storedUser.authenticationToken!);

    switch (response.statusCode) {
      case 200:
        // Authentication success, return user
        User pulledUser = User.fromJsonNoAuth(jsonDecode(response.body)["data"],
            storedUser.password!, storedUser.authenticationToken!);
        saveUser(pulledUser);
        return pulledUser;
      default:
        // Authentication failed, attempt reauthentication
        var responseWithNewAuth =
            await login(storedUser.email, storedUser.password!);

        switch (responseWithNewAuth.statusCode) {
          case 200:
            // Reauthentication success, return user with auth
            var json = jsonDecode(responseWithNewAuth.body);
            User user = User.fromJson(json["data"], storedUser.password!);
            saveUser(user);
            return user;

          default:
            // Reauthentication failed, return saved user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to reauthenticate."),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return storedUser;
        }
    }
  }

  saveUser(User user) async {
    await FlutterKeychain.put(
        key: "user", value: jsonEncode(user.toJson()).toString());
  }
}
