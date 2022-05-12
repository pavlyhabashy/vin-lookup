import 'package:flutter/material.dart';
import 'package:vin_lookup/classes/vehicle.dart';

class RecallsScreen extends StatelessWidget {
  final Vehicle vehicle;
  const RecallsScreen({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recalls")),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("Make"),
                      Text(vehicle.make),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Model"),
                      Text(vehicle.model),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Year"),
                      Text(vehicle.year),
                    ],
                  ),
                ],
              ),
              ...vehicle.recalls!.map(
                (recall) {
                  return Text('Entry ${recall.summary}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
