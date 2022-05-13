class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String country;
  String? authenticationToken;
  String? password;

  User(
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.country,
    this.authenticationToken,
    this.password,
  );

  User.fromJson(Map<String, dynamic> json, String pass)
      : id = json['id'].toString(),
        name = json['name'],
        email = json["email"],
        phoneNumber = json["phone_number"],
        country = json["country"],
        authenticationToken = json["authentication_token"],
        password = pass;

  User.fromJsonNoAuth(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'],
        email = json["email"],
        phoneNumber = json["phone_number"],
        country = json["country"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'country': country,
        'authentication_token': authenticationToken,
        'password': password,
      };
}
