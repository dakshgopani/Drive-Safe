import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class QRCodeScreen extends StatefulWidget {
  final String roomDetails;

  QRCodeScreen({required this.roomDetails});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  // Function to request storage/gallery permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted) {
        return true;
      }

      if (await Permission.storage.isPermanentlyDenied ||
          await Permission.photos.isPermanentlyDenied) {
        _showPermissionDialog();
        return false;
      }
    }

    return false;
  }

  // Show a dialog to take the user to app settings
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "Storage permission is needed to save QR codes. Please enable it in app settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open app settings
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // Function to generate and save QR Code to gallery
  Future<void> _saveQRCodeToGallery() async {
    try {
      // Request permission before proceeding
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) return;

      // Generate QR Code as an image
      final qrCode = QrPainter(
        data: widget.roomDetails,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final tempDir = await getTemporaryDirectory();
      final qrFile = File('${tempDir.path}/qr_code.png');

      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      const double qrSize = 300; // QR code size
      const double padding = 50; // White border around the QR code
      const double totalSize = qrSize + (2 * padding); // Total image size

      // Draw a white background
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, totalSize, totalSize), paint);

      // Move the canvas to position the QR code properly
      canvas.translate(padding, padding);

      // Draw the QR code on the translated canvas
      qrCode.paint(canvas, const Size(qrSize, qrSize));

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(totalSize.toInt(), totalSize.toInt());
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      await qrFile.writeAsBytes(buffer);

      // Save the image to the gallery using photo_manager
      final assetEntity = await PhotoManager.editor.saveImage(
        buffer,
        title: "qr_code_${DateTime.now().millisecondsSinceEpoch}.png",
        filename: 'qrCode.png',
      );

      if (assetEntity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR Code saved to gallery! 🎉")),
        );
      } else {
        throw Exception("Failed to save the QR Code.");
      }
    } catch (e) {
      print("Error saving image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code"),
        centerTitle: true,
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Code Display
            QrImageView(
              data: widget.roomDetails,
              size: 250,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),

            // Save QR Code Button
            ElevatedButton.icon(
              onPressed: _saveQRCodeToGallery,
              icon: const Icon(Icons.save),
              label: const Text("Save QR Code"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Exit Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Pops the second screen
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Exit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
