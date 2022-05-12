import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:string_validator/string_validator.dart';
import 'package:vin_lookup/classes/recall.dart';
import 'package:vin_lookup/classes/vehicle.dart';
import 'package:vin_lookup/networking.dart/shared.dart';
import 'package:vin_lookup/screens/recalls_screen.dart';

class VinLookupScreen extends StatefulWidget {
  const VinLookupScreen({Key? key}) : super(key: key);

  @override
  State<VinLookupScreen> createState() => _VinLookupScreenState();
}

class _VinLookupScreenState extends State<VinLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _vin = "5J8TB1H29CA003675";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
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
              ),
              TextButton(
                onPressed: _submit,
                child: const Text(
                  'Look Up',
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

  Future<Response> vinGetRequest(String vin) {
    return get(
      Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$vin?format=json'),
    );
  }

  Future<Response> recallGetRequest(String make, String model, String year) {
    return get(
      Uri.parse(
          'https://api.nhtsa.gov/recalls/recallsByVehicle?make=$make&model=$model&modelYear=$year'),
    );
  }

  _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!(await checkConnection())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await _lookUpVIN();
    }
  }

  _lookUpVIN() async {
    var response = await vinGetRequest(_vin);
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

    if (make == "null" || model == "null" || year == "null") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("VIN not found. Please check your VIN and try again."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Vehicle vehicle = Vehicle(make: make, model: model, year: year);

    var recallResponse = await recallGetRequest(make, model, year);
    var recallResults = jsonDecode(recallResponse.body);
    List<Recall> recalls = List.empty(growable: true);
    for (var result in recallResults["results"]) {
      recalls.add(Recall.fromJson(result));
    }
    vehicle.setRecalls(recalls);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => RecallsScreen(vehicle: vehicle),
      ),
    );
  }
}
