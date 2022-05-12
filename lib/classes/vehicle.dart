import 'package:vin_lookup/classes/recall.dart';

class Vehicle {
  final String make;
  final String model;
  final String year;
  List<Recall>? recalls;

  Vehicle({
    required this.make,
    required this.model,
    required this.year,
    this.recalls,
  });

  List<Recall>? getRecalls() {
    return recalls;
  }

  setRecalls(List<Recall> recalls) {
    this.recalls = recalls;
  }
}
