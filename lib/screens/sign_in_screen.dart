import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:string_validator/string_validator.dart';
import 'package:vin_lookup/classes/user.dart';
import 'package:vin_lookup/networking.dart/authentication.dart';
import 'package:vin_lookup/networking.dart/shared.dart';
import 'package:vin_lookup/screens/vin_lookup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("FAKE FIXD")),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
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
                        _buildLoginButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTF() {
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
          // Disable spaces
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return RoundedLoadingButton(
      elevation: 0,
      color: Theme.of(context).primaryColor,
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
      controller: _btnController,
      onPressed: _submit,
    );
  }

  Widget _buildPasswordTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 10.0,
      ),
      child: TextFormField(
        initialValue: _password,
        decoration: const InputDecoration(labelText: 'Password'),
        validator: (input) =>
            input!.isEmpty ? 'Must be at least 1 character long' : null,
        onChanged: (input) => _password = input,
        obscureText: true,
        inputFormatters: [
          // Disable spaces
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
      ),
    );
  }

  _loginButtonErrorReset() {
    _btnController.error();
    Future.delayed(const Duration(seconds: 1), () {
      _btnController.reset();
    });
  }

  _submit() async {
    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Check input params are valid
    if (!_formKey.currentState!.validate()) {
      _loginButtonErrorReset();
      return;
    }

    // Check internet connection
    if (!(await checkConnection(context))) {
      _loginButtonErrorReset();
      return;
    }

    // Save form state
    _formKey.currentState!.save();

    // Attempt login
    var response = await Authentication().login(_email!, _password!);
    switch (response.statusCode) {
      case 200: // Success

        // Create and save user info and credentials
        User user =
            User.fromJson(jsonDecode(response.body)["data"], _password!);
        user.password = _password;
        Authentication().saveUser(user);

        // Go to VIN Lookup Screen
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => const VinLookupScreen(),
          ),
        );
        _btnController.reset();

        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong. Please try again."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loginButtonErrorReset();
    }
  }
}
