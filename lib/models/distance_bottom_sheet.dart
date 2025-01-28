import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DistanceBottomSheet extends StatelessWidget {
  final Map<String, dynamic>? placeDetails;
  final VoidCallback? startLocationTracking;

  const DistanceBottomSheet({
    Key? key,
    this.placeDetails,
    this.startLocationTracking,
  }) : super(key: key);

  _makingPhoneCall(String phoneNumber) async {
    var url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // Adjust initial height
      minChildSize: 0.05, // Minimum height to keep it partially open
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, -2),
                blurRadius: 5,
              ),
            ],
          ),
          child: placeDetails == null
              ? _buildLoading()
              : _buildContent(context, scrollController),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ScrollController scrollController) {
    int reviewCount = (placeDetails?['reviews'] as List?)?.length ?? 0;
    return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              placeDetails?['name'] ?? 'Unknown Place',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Add functionality for similar places
              },
              child: const Text(
                "See similar places",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    if ((placeDetails?['rating'] ?? 0) >= index + 1) {
                      return const Icon(Icons.star,
                          color: Colors.amber, size: 18);
                    } else if ((placeDetails?['rating'] ?? 0) > index &&
                        (placeDetails?['rating'] ?? 0) < index + 1) {
                      return const Icon(Icons.star_half,
                          color: Colors.amber, size: 18);
                    } else {
                      return Icon(Icons.star_border,
                          color: Colors.grey.shade300, size: 18);
                    }
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${placeDetails?['rating']?.toStringAsFixed(1) ?? 'N/A'} ($reviewCount)',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              placeDetails?['formatted_address'] ?? 'No address available',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                  onPressed: () {
                    // Add functionality for directions
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.navigation),
                  label: const Text('Start'),
                  onPressed: () {
                    if (startLocationTracking != null) {
                      startLocationTracking!();
                      Navigator.pop(context);
                    } else {
                      print('Start location tracking function is null.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (placeDetails?['formatted_phone_number'] != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    onPressed: () {
                      _makingPhoneCall(placeDetails?['formatted_phone_number']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ));
  }
}