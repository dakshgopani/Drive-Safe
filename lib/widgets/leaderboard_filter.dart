import 'package:flutter/material.dart';

class LeaderboardFilter extends StatelessWidget {
  final String selectedMetric;
  final Function(String) onMetricChanged;

  const LeaderboardFilter({
    super.key,
    required this.selectedMetric,
    required this.onMetricChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedMetric,
                decoration: const InputDecoration(
                  labelText: 'Metric',
                  border: OutlineInputBorder(),
                ),
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
            )
          ],
        ),
      ),
    );
  }
}