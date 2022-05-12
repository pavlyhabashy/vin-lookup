import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_validator/string_validator.dart';
import 'package:vin_lookup/classes/user.dart';
import 'package:vin_lookup/networking.dart/authentication.dart';
import 'package:vin_lookup/screens/vin_lookup_screen.dart';

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
      var response = await Authentication().login(_email, _password);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        User user = User.fromJson(json["data"]);
        Authentication().saveUser(user);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => const VinLookupScreen(),
          ),
        );
        // var userData =
        //     await Authentication().getUser(user.id, user.authenticationToken);
        // print(userData.statusCode);
        // print(jsonDecode(userData.body));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Column(
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
    );
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
            !isEmail(input!) ? 'Please enter a valid email' : null,
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
