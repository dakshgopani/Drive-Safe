import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:uuid/uuid.dart';
import '../../api/apis.dart';
import '../../services/location_services.dart';
import 'qr_code_screen.dart';
import 'package:geolocator/geolocator.dart';

class CreateRoomPage extends StatefulWidget {
  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController numberOfCarsController = TextEditingController();
  String? generatedRoomCode;
  bool isAdmin = true;
  List<dynamic> _searchResults = [];
  bool _isFetching = false;
  List<dynamic> placeDetails = [];
  Map<String, bool> _fieldErrors = {
    'roomName': false,
    'startLocation': false,
    'destination': false,
    'numberOfCars': false,
  };
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    GeoPoint? location = await LocationService.initializeLocation(context);

    if (location != null) {
      setState(() {
        startLocationController.text = "Your location";
      });
    }
  }

  void _fetchSearchResultsDebounced(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    if (_isFetching) return; // Prevent multiple fetches

    _isFetching = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      ApiService.fetchSearchResults(query).then((results) {
        setState(() {
          _searchResults = results;
          _isFetching = false;
        });
      }).catchError((e) {
        print('Error fetching search results: $e');
        _isFetching = false;
      });
    });
  }

  bool validateFields() {
    bool isValid = true;

    Map<String, bool> errors = {
      'roomName': false,
      'startLocation': false,
      'destination': false,
      'numberOfCars': false,
    };

    if (roomNameController.text.trim().isEmpty) {
      errors['roomName'] = true;
      isValid = false;
    }

    if (startLocationController.text.trim().isEmpty) {
      errors['startLocation'] = true;
      isValid = false;
    }

    if (destinationController.text.trim().isEmpty) {
      errors['destination'] = true;
      isValid = false;
    }

    if (numberOfCarsController.text.trim().isEmpty) {
      errors['numberOfCars'] = true;
      isValid = false;
    }

    setState(() {
      _fieldErrors = errors;
    });

    return isValid;
  }

  void createRoom() async {
    if (!validateFields()) {
      return;
    }

    final uuid = const Uuid();
    final String roomCode = uuid.v4();

    final Map<String, dynamic> roomData = {
      "roomCode": roomCode,
      "roomName": roomNameController.text.trim(),
      "startLocation": startLocationController.text.trim(),
      "destination": destinationController.text.trim(),
      "destination_location": {
        "latitude": placeDetails[0].latitude,
        "longitude": placeDetails[0].longitude
      },
      "numberOfCars": int.tryParse(numberOfCarsController.text) ?? 0,
      "createdAt": firestore.FieldValue.serverTimestamp(),
    };

    try {
      await firestore.FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomCode)
          .set(roomData);

      final String roomDetails = '''
    {
      "roomCode": "$roomCode",
      "roomName": "${roomNameController.text.trim()}",
      "startLocation": "${startLocationController.text.trim()}",
      "destination": "${destinationController.text.trim()}",
      "destination_location": {
        "latitude": ${placeDetails[0].latitude},
        "longitude": ${placeDetails[0].longitude}
      },
      "numberOfCars": ${roomData["numberOfCars"]}
    }
    ''';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRCodeScreen(roomDetails: roomDetails),
        ),
      );
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create room: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Room")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: constraints.maxWidth > 600
                              ? 600
                              : constraints.maxWidth,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTextField(
                                controller: roomNameController,
                                label: "Name of Room",
                                errorKey: 'roomName',
                              ),
                              SizedBox(height: 16),
                              _buildTextField(
                                controller: startLocationController,
                                label: "Start Location",
                                errorKey: 'startLocation',
                                onChanged: (query) {
                                  setState(() {
                                    _activeController = startLocationController;
                                  });
                                  if (query.isNotEmpty && query != "Your location") {
                                    _fetchSearchResultsDebounced(query);
                                  }
                                },
                              ),
                              SizedBox(height: 16),
                              _buildTextField(
                                controller: destinationController,
                                label: "Destination Location",
                                errorKey: 'destination',
                                onChanged: (query) {
                                  setState(() {
                                    _activeController = destinationController;
                                  });
                                  if (query.isNotEmpty) {
                                    _fetchSearchResultsDebounced(query);
                                  }
                                },
                              ),
                              if (_searchResults.isNotEmpty) _buildSearchResults(),
                              SizedBox(height: 16),
                              _buildTextField(
                                controller: numberOfCarsController,
                                label: "Number of Cars",
                                errorKey: 'numberOfCars',
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: createRoom,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  "Create Room",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String errorKey,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        errorText: _fieldErrors[errorKey]! ? "Please enter $label" : null,
        errorBorder: _fieldErrors[errorKey]!
            ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 2),
        )
            : null,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 250, // Restrict height to avoid covering the whole page
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          height: 10,
          color: Colors.grey[300],
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          final selectedResult = {
            'description': _searchResults[index]['description'],
            'place_id': _searchResults[index]['place_id']
          };

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_outlined, color: Colors.blueAccent, size: 24),
            ),
            title: Text(
              selectedResult['description']!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            onTap: () async {
              try {
                // Fetch place details using the selected place_id
                placeDetails = await ApiService.fetchPlaceDetails(selectedResult['place_id']);

                // Update the respective text field
                if (_activeController == startLocationController) {
                  startLocationController.text = selectedResult['description']!;
                } else if (_activeController == destinationController) {
                  destinationController.text = selectedResult['description']!;
                }

                // Log or store the selected result
                print("✅ Selected Result: $selectedResult");

                setState(() {
                  _searchResults.clear();
                });
              } catch (e) {
                print("❌ Error fetching place details: $e");
              }
            },
          );
        },
      ),
    );
  }
}