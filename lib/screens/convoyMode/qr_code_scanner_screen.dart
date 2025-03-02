import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
as ml_kit;
import 'dart:ui';

import '../../utils/app_state.dart';
import 'waiting_room_screen.dart';

class ScanQRCodeScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ScanQRCodeScreen(
      {Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  String scannedData = "";
  final mobile_scanner.MobileScannerController _mobileScannerController =
  mobile_scanner.MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF4),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Scan QR Code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                mobile_scanner.MobileScanner(
                  controller: _mobileScannerController,
                  onDetect: (mobile_scanner.BarcodeCapture barcodeCapture) {
                    for (final barcode in barcodeCapture.barcodes) {
                      if (barcode.rawValue != null &&
                          barcode.rawValue!.isNotEmpty) {
                        _processScannedData(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 3),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _selectedImage == null
                        ? null
                        : Center(
                      child: Image.file(
                        File(_selectedImage!.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (scannedData.isNotEmpty) _buildScannedDataCard(),
                  if (scannedData.isEmpty)
                    const Center(
                      child: Text(
                        "Scan a valid QR code to proceed.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _buildStyledButton(
                      label: "Upload from Gallery",
                      onPressed: _pickImageFromGallery),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedDataCard() {
    Map<String, String> formattedData = _parseScannedData(scannedData);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF448AFF), Color(0xFF2979FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Scanned QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF448AFF), width: 1.5),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: formattedData.isNotEmpty
                        ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: formattedData.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${entry.key}: ",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList())
                        : Center(
                      child: Text(
                        scannedData,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: _buildStyledButton(
                  label: "Proceed to join room",
                  onPressed: () {
                    Map<String, String> parsedData = _parseScannedData(scannedData);
                    String roomCode = parsedData["roomCode"] ?? "";
                    String numberOfCarsStr = parsedData["numberOfCars"] ?? "4"; // Default to 4 if not found
                    int numberOfCars = int.tryParse(numberOfCarsStr) ?? 4; // Parse to int, default to 4

                    if (roomCode.isNotEmpty) {
                      // Store the roomCode in the global state
                      appState.roomCode = roomCode;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoomScreen(
                            userName: widget.userName,
                            roomId: roomCode,
                            maxAllowedUsers: numberOfCars, // Pass numberOfCars
                          ),
                        ),
                      );
                    } else {
                      _showSnackBar("No valid room code found in QR data.");
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton(
      {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        elevation: 5,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showScannedDataDialog(String rawData) {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF448AFF), Color(0xFF2979FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Scanned QR Code Data",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatScannedData(rawData),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _processScannedData(String rawData) {
    Map<String, String> parsedData = _parseScannedData(rawData);
    String roomCode = parsedData["roomCode"] ?? "";

    setState(() {
      scannedData = rawData;
    });

    _showScannedDataDialog(rawData);
  }

  String _formatScannedData(String rawData) {
    try {
      final decodedJson = json.decode(rawData);
      if (decodedJson is Map<String, dynamic>) {
        return decodedJson.entries
            .map((entry) => "${entry.key}: ${entry.value}")
            .join("\n");
      }
    } catch (e) {
      // If JSON parsing fails, return raw data without {} and extra quotes
    }
    return rawData.replaceAll(RegExp(r'[\{\}"\\]'), '');
  }

  Map<String, String> _parseScannedData(String rawData) {
    Map<String, String> parsedData = {};

    try {
      final decodedJson = json.decode(rawData);
      if (decodedJson is Map<String, dynamic>) {
        decodedJson.forEach((key, value) {
          parsedData[key] = value.toString();
        });
        return parsedData;
      }
    } catch (e) {
      String cleanedData = rawData.replaceAll(RegExp(r'[\{\}"\[\]]'), '');
      List<String> keyValuePairs = cleanedData.split(',');
      for (String pair in keyValuePairs) {
        List<String> entry = pair.split(':');
        if (entry.length == 2) {
          parsedData[entry[0].trim()] = entry[1].trim();
        }
      }
      if (parsedData.isEmpty) {
        parsedData["Scanned Data"] = cleanedData;
      }
    }
    return parsedData;
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = image);

      final String? qrData = await _decodeQRCode(File(image.path));
      if (qrData != null) {
        setState(() => scannedData = qrData);
        _showScannedDataDialog(qrData);
      } else {
        _showSnackBar("Failed to detect QR code. Try a clearer image.");
      }
    } else {
      _showSnackBar("No image was selected.");
    }
  }

  Future<String?> _decodeQRCode(File imageFile) async {
    final ml_kit.InputImage inputImage = ml_kit.InputImage.fromFile(imageFile);
    final ml_kit.BarcodeScanner barcodeScanner = ml_kit.BarcodeScanner();

    final List<ml_kit.Barcode> barcodes =
    await barcodeScanner.processImage(inputImage);
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        return rawValue;
      }
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blueAccent),
    );
  }
}