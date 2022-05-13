import 'package:flutter/material.dart';
import 'package:vin_lookup/classes/user.dart';
import 'package:vin_lookup/networking.dart/authentication.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: Authentication().getStoredUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
            ),
            body: SingleChildScrollView(
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
