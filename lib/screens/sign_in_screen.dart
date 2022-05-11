import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "flutter@example.com";
  String _password = "Ox8CiV2eRIO72m19euLh";

  _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var response = await login(_email, _password);
      print(response.statusCode);

      var json = jsonDecode(response.body);
      print(json);
      var id = json["data"]["id"].toString();
      var auth = json["data"]["authentication_token"];

      var userData = await getUser(id, auth);
      print(userData.statusCode);
      print(jsonDecode(userData.body));
    }
  }

  Future<http.Response> login(String email, String password) {
    return http.post(
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

  Future<http.Response> getUser(String id, String auth) {
    return http.get(
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
        future: null,
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Sign In"),
              ),
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildEmailTF(),
                          _buildPasswordTF(),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: 250.0,
                            child: TextButton(
                              onPressed: _submit,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Padding _buildPasswordTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 10.0,
      ),
      child: TextFormField(
        initialValue: _password,
        decoration: const InputDecoration(labelText: 'Password'),
        validator: (input) =>
            input!.length < 6 ? 'Must be at least 6 characters' : null,
        onChanged: (input) => _password = input,
        obscureText: true,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
      ),
    );
  }

  Padding _buildEmailTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 10.0,
      ),
      child: TextFormField(
        initialValue: _email,
        decoration: const InputDecoration(labelText: 'Email'),
        validator: (input) =>
            !input!.contains('@') ? 'Please enter a valid email' : null,
        onChanged: (input) => _email = input,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: true,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
      ),
    );
  }
}
