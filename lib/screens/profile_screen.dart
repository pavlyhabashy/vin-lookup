import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vin_lookup/classes/user.dart';
import 'package:vin_lookup/networking.dart/authentication.dart';
import 'package:vin_lookup/networking.dart/shared.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: pullUserAndReauthenticate(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.shade50,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(height: 48),
                      _buildUserInfoRow(
                        icon: Icons.email,
                        title: "Email",
                        info: user.email,
                      ),
                      _buildUserInfoRow(
                        icon: Icons.phone_rounded,
                        title: "Phone",
                        info: user.phoneNumber,
                      ),
                      _buildUserInfoRow(
                        icon: Icons.location_on,
                        title: "Country",
                        info: user.country,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<User> pullUserAndReauthenticate() async {
    // Get stored user from keychain
    User storedUser = await Authentication().getStoredUser();

    // No internet connection, return saved user
    if (!(await checkConnection(context))) {
      return storedUser;
    }

    // GET user info
    Response response = await Authentication()
        .getUser(storedUser.id, storedUser.authenticationToken!);

    switch (response.statusCode) {
      case 200:
        // Authentication success, return user
        User pulledUser = User.fromJsonNoAuth(jsonDecode(response.body)["data"],
            storedUser.password!, storedUser.authenticationToken!);
        Authentication().saveUser(pulledUser);
        return pulledUser;
      default:
        // Authentication failed, attempt reauthentication
        var responseWithNewAuth = await Authentication()
            .login(storedUser.email, storedUser.password!);

        switch (responseWithNewAuth.statusCode) {
          case 200:
            // Reauthentication success, return user with auth
            var json = jsonDecode(responseWithNewAuth.body);
            User user = User.fromJson(json["data"], storedUser.password!);
            Authentication().saveUser(user);
            return user;

          default:
            // Reauthentication failed, return saved user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to reauthenticate."),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return storedUser;
        }
    }
  }

  Widget _buildUserInfoRow(
      {required IconData icon, required String title, required String info}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8.0),
              Text(title),
            ],
          ),
          Text(info),
        ],
      ),
    );
  }
}
