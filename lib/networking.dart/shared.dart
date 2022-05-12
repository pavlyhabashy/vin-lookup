import 'dart:io';

import 'package:flutter/material.dart';

Future<bool> checkConnection(BuildContext context) async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No internet connection."),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }
  return false;
}
