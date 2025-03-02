import 'package:algorithm_avengers_ves_final/screens/drawer/trip_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripHistoryScreen extends StatefulWidget {
  @override
  _TripHistoryScreenState createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  Future<List<Map<String, dynamic>>>? _tripsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tripsFuture = fetchUserTrips();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '${hours > 0 ? '$hours hr ' : ''}${minutes > 0 ? '$minutes min' : '< 1 min'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
                          iconTheme: IconThemeData(color: Colors.white), // Change arrow color

        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Trip History',
                 style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2,color: Colors.white),

        ),
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _tripsFuture = fetchUserTrips();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 80,
                    color: Colors.blueAccent.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No trips recorded yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your completed trips will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          List<Map<String, dynamic>> trips = snapshot.data!;

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: Radius.circular(10),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                var trip = trips[index];
                double distance = double.tryParse(trip['totalDistance'].toString()) ?? 0;
                String distanceText = distance >= 1000
                    ? '${(distance / 1000).toStringAsFixed(1)} km'
                    : '${distance.toStringAsFixed(0)} m';

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailScreen(trip: trip),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  color: Colors.blueAccent,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDate(trip['startTime']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Trip ${index + 1}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.blueAccent,
                                size: 28,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(height: 1),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTripStat(
                                  Icons.speed,
                                  '${trip['averageSpeed']} km/h',
                                  'Speed'
                              ),
                              _buildTripStat(
                                  Icons.straighten,
                                  distanceText,
                                  'Distance'
                              ),
                              _buildTripStat(
                                  Icons.timer,
                                  formatDuration(trip['tripDuration']),
                                  'Duration'
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchUserTrips() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('drives')
      .orderBy('timestamp', descending: true)
      .get();

  return querySnapshot.docs.map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      'averageSpeed': data['averageSpeed'] ?? "N/A",
      'totalDistance': data['totalDistance'] ?? "0",
      'tripDuration': data['tripDuration'] ?? 0,
      'startTime': (data['startTime'] as Timestamp).toDate(),
      'endTime': (data['endTime'] as Timestamp).toDate(),
      'startLocation': {
        'latitude': data['startLocation']?['latitude'] ?? 0.0,
        'longitude': data['startLocation']?['longitude'] ?? 0.0,
      },
      'destination': {
        'latitude': data['destination']?['latitude'] ?? 0.0,
        'longitude': data['destination']?['longitude'] ?? 0.0,
      },
    };
  }).toList();
}