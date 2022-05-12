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
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                _buildVehicleInfo(context),
                ...vehicle.recalls!.map(
                  (recall) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              _buildRecallInfoBlock(
                                  context, "Component", recall.component),
                              const SizedBox(height: 16.0),
                              _buildRecallInfoBlock(
                                  context, "Summary", recall.summary),
                              const SizedBox(height: 16.0),
                              _buildRecallInfoBlock(
                                  context, "Consequence", recall.consequence),
                              const SizedBox(height: 16.0),
                              _buildRecallInfoBlock(
                                  context, "Remedy", recall.remedy),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildVehicleInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildVehicleInfoColumn(context, "Make", vehicle.make),
          _buildVehicleInfoColumn(context, "Model", vehicle.model),
          _buildVehicleInfoColumn(context, "Year", vehicle.year),
        ],
      ),
    );
  }

  Column _buildVehicleInfoColumn(
      BuildContext context, String title, String info) {
    return Column(
      children: [
        Text(title),
        Text(
          info,
          style: Theme.of(context).textTheme.headline5,
        ),
      ],
    );
  }

  Widget _buildRecallInfoBlock(
      BuildContext context, String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 8),
        Text('Entry $info'),
      ],
    );
  }
}
