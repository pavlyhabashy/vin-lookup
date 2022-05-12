import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class VinLookupScreen extends StatefulWidget {
  const VinLookupScreen({Key? key}) : super(key: key);

  @override
  State<VinLookupScreen> createState() => _VinLookupScreenState();
}

class _VinLookupScreenState extends State<VinLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _vin = "5J8TB1H29CA003675";

  Future<Response> vinLookup(String vin) {
    return get(
      Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$vin?format=json'),
    );
  }

  Future<Response> recallLookup(String make, String model, String year) {
    return get(
      Uri.parse(
          'https://api.nhtsa.gov/recalls/recallsByVehicle?make=$make&model=$model&modelYear=$year'),
    );
  }

  _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var response = await vinLookup(_vin);
      var results = jsonDecode(response.body)["Results"] as List;
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

      print("$make, $model, $year");

      var recallResponse = await recallLookup(make, model, year);
      var recallResults = jsonDecode(recallResponse.body);

      for (var result in recallResults["results"]) {
        print(result["ReportReceivedDate"]);
        print(result["Component"]);
        print(result["Summary"]);
        print(result["Consequence"]);
        print(result["Remedy"]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _vin,
                decoration: const InputDecoration(labelText: 'Enter Your VIN'),
                keyboardType: TextInputType.text,
                autocorrect: false,
                enableSuggestions: true,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                onChanged: (input) => _vin = input,
              ),
              TextButton(
                onPressed: _submit,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
