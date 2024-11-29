import 'package:flutter/material.dart';

class LeaderboardFilter extends StatelessWidget {
  final String selectedMetric;
  final String? selectedRegion;
  final Function(String) onMetricChanged;
  final Function(String?) onRegionChanged;

  const LeaderboardFilter({
    Key? key,
    required this.selectedMetric,
    required this.selectedRegion,
    required this.onMetricChanged,
    required this.onRegionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: selectedMetric,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'safetyScore',
                  child: Text('Safety Score'),
                ),
                DropdownMenuItem(
                  value: 'ecoScore',
                  child: Text('Eco Score'),
                ),
                DropdownMenuItem(
                  value: 'totalDistance',
                  child: Text('Total Distance'),
                ),
              ],
              onChanged: (value) {
                if (value != null) onMetricChanged(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String?>(
              value: selectedRegion,
              isExpanded: true,
              hint: const Text('All Regions'),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Regions'),
                ),
                DropdownMenuItem(
                  value: 'north',
                  child: Text('North'),
                ),
                DropdownMenuItem(
                  value: 'south',
                  child: Text('South'),
                ),
                DropdownMenuItem(
                  value: 'east',
                  child: Text('East'),
                ),
                DropdownMenuItem(
                  value: 'west',
                  child: Text('West'),
                ),
              ],
              onChanged: onRegionChanged,
            ),
          ),
        ],
      ),
    );
  }
}