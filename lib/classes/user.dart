class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String country;
  final String authenticationToken;

  User(
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.country,
    this.authenticationToken,
  );

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'],
        email = json["email"],
        phoneNumber = json["phone_number"],
        country = json["country"],
        authenticationToken = json["authentication_token"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'country': country,
        'authentication_token': authenticationToken,
      };
}
