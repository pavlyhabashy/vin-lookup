import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vin_lookup/classes/recall.dart';
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
      body: (vehicle.recalls!.isEmpty)
          ? _buildMainColumn(context)
          : SingleChildScrollView(
              child: _buildMainColumn(context),
            ),
    );
  }

  Widget _buildMainColumn(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildVehicleInfo(context),
          _buildRecallCards(context),
        ],
      ),
    );
  }

  Widget _buildRecallCards(BuildContext context) {
    if (vehicle.recalls!.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No Recalls"),
        ),
      );
    }
    return Column(
      children: [
        ...vehicle.recalls!
            .asMap()
            .map(
              (index, recall) {
                return MapEntry(
                  index,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shadowColor: Colors.transparent,
                      color: Colors.green.shade50,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, top: 4.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Reported: ${_formatDate(recall)}",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      "${index + 1}/${vehicle.recalls?.length}",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
            .values
            .toList(),
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

  Widget _buildVehicleInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8.0,
          children: [
            _buildVehicleInfoColumn(context, "Make", vehicle.make),
            _buildVehicleInfoColumn(context, "Model", vehicle.model),
            _buildVehicleInfoColumn(context, "Year", vehicle.year),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoColumn(
      BuildContext context, String title, String info) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          info,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  String _formatDate(Recall recall) {
    DateFormat inputFormat = DateFormat("dd/mm/yyyy");
    var inputDate = inputFormat.parse(recall.reportReceivedDate);
    DateFormat outputFormat = DateFormat("MMMM d, yyyy");
    String outputDate = outputFormat.format(inputDate);
    return outputDate;
  }
}
