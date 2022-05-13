import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:string_validator/string_validator.dart';
import 'package:vin_lookup/classes/recall.dart';
import 'package:vin_lookup/classes/vehicle.dart';
import 'package:vin_lookup/networking.dart/shared.dart';
import 'package:vin_lookup/networking.dart/vin_lookup_requests.dart';
import 'package:vin_lookup/screens/profile_screen.dart';
import 'package:vin_lookup/screens/recalls_screen.dart';

class VinLookupScreen extends StatefulWidget {
  const VinLookupScreen({Key? key}) : super(key: key);

  @override
  State<VinLookupScreen> createState() => _VinLookupScreenState();
}

class _VinLookupScreenState extends State<VinLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String _vin = "WAUYGAFC6CN174200";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await FlutterKeychain.remove(key: "user");
              Navigator.pop(context);
            },
          ),
          appBar: AppBar(
            title: const Text("Vin Lookup"),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
                icon: const Icon(Icons.person),
              )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildVINInputTF(),
                    const SizedBox(height: 32),
                    _buildLookupButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLookupButton(BuildContext context) {
    return RoundedLoadingButton(
      color: Theme.of(context).primaryColor,
      child: const Text('Look Up VIN', style: TextStyle(color: Colors.white)),
      controller: _btnController,
      onPressed: _submit,
    );
  }

  Widget _buildVINInputTF() {
    return TextFormField(
      initialValue: _vin,
      decoration: const InputDecoration(labelText: 'Enter Your VIN'),
      keyboardType: TextInputType.text,
      autocorrect: false,
      enableSuggestions: false,
      validator: (input) {
        if (input!.length != 17) {
          return 'Must be at least 17 characters';
        }
        if (!isAlphanumeric(input)) {
          return 'Must be letters and numbers';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      onChanged: (input) => _vin = input,
    );
  }

  _loginButtonErrorReset() {
    _btnController.error();
    Future.delayed(const Duration(seconds: 1), () {
      _btnController.reset();
    });
  }

  _lookUpVIN() async {
    // GET VIN using NHTSA API
    var response = await vinGetRequest(_vin);
    var results = jsonDecode(response.body)["Results"] as List<dynamic>;
    String make = "", model = "", year = "";
    for (var result in results) {
      switch (result["Variable"]) {
        case "Make":
          make = result["Value"].toString();
          break;
        case "Model":
          model = result["Value"].toString();
          break;
        case "Model Year":
          year = result["Value"].toString();
          break;
      }
    }

    // If fields are null, then no car found with VIN input.
    if (make == "null" || model == "null" || year == "null") {
      _loginButtonErrorReset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("VIN not found. Please check your VIN and try again."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create vehicle object
    Vehicle vehicle = Vehicle(make: make, model: model, year: year);

    // GET recalls by make, model, year
    var recallResponse = await recallGetRequest(make, model, year);
    var recallResults = jsonDecode(recallResponse.body);
    List<Recall> recalls = List.empty(growable: true);
    for (var result in recallResults["results"]) {
      recalls.add(Recall.fromJson(result));
    }
    vehicle.setRecalls(recalls);

    // Navigate to Recalls screen
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => RecallsScreen(vehicle: vehicle),
      ),
    );
    _btnController.reset();
  }

  _submit() async {
    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Check input param is valid
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

    // Look up VIN
    await _lookUpVIN();
  }
}
