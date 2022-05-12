import 'package:http/http.dart';

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
