import 'package:flutter/material.dart';
import 'package:vin_lookup/networking.dart/authentication.dart';
import 'package:vin_lookup/screens/sign_in_screen.dart';
import 'package:vin_lookup/screens/vin_lookup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIN Lookup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme.of(context).copyWith(elevation: 0),
      ),
      home: FutureBuilder<bool>(
        future: Authentication().autoLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.data == false) {
            return const SignInScreen();
          }
          return const VinLookupScreen();
        },
      ),
    );
  }
}
