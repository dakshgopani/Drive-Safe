import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreScreen extends StatefulWidget {
  final String userId;

  const StoreScreen({super.key, required this.userId});

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _userPoints = 0; // Stores total user points

  List<Map<String, dynamic>> medicines = [
    {
      'name': 'Car Wash Coupon',
      'points': 10,
      'image': 'assets/images/store/car_wash_coupon_img.png'
    },
    {
      'name': 'Car Sun Shade',
      'points': 20,
      'image': 'assets/images/store/car_sun_shade_img.png'
    },
    {
      'name': 'Car Parking Spot',
      'points': 30,
      'image': 'assets/images/store/car_parking_spot_img.png'
    },
    {
      'name': 'Mystery Box',
      'points': 40,
      'image': 'assets/images/store/mystery_box_img.png'
    },
    {
      'name': 'Amazon Gift Card',
      'points': 50,
      'image': 'assets/images/store/amazon_gift_card_img.png'
    },
    {
      'name': 'EV Charging Spot',
      'points': 60,
      'image': 'assets/images/store/ev_charging_spot_img.png'
    },
    {
      'name': 'Car Skin',
      'points': 70,
      'image': 'assets/images/store/car_skins_img.png'
    },
    {
      'name': 'Toll Free Pass',
      'points': 80,
      'image': 'assets/images/store/toll_free_pass_img.png'
    },
    {
      'name': 'Custom Plate',
      'points': 90,
      'image': 'assets/images/store/custom_licence_plate.png'
    },
    {
      'name': 'Emergency Kit',
      'points': 100,
      'image': 'assets/images/store/emergency_kit_img.png'
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  Future<void> _fetchUserPoints() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userPoints = (userDoc.data() as Map<String, dynamic>)['points'] ?? 0;
        });
      }
    } catch (e) {
      print("❌ Error fetching points: $e");
    }
  }

  Future<void> _redeemReward(int cost, String medicineName) async {
    if (_userPoints >= cost) {
      _showLoadingDialog(); // ✅ Show loader first

      setState(() {
        _userPoints -= cost;
      });

      // ✅ Perform Firestore update in the background
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'points': _userPoints});

      Navigator.pop(context); // ✅ Close the loader
      Navigator.pop(context); // ✅ Close bottom sheet immediately

      _showSuccessDialog(medicineName); // ✅ Show success pop-up
    } else {
      Navigator.pop(
          context); // ✅ Close the bottom sheet BEFORE showing Snackbar

      Future.delayed(const Duration(milliseconds: 200), () {
        // ✅ Ensure UI update before showing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Not enough points!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

// ✅ Loader Dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while loading
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF448AFF)),
            // Loader
            SizedBox(height: 16),
            Text(
              "Processing your request...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Raleway',
              ),
            ),
          ],
        ),
      ),
    );
  }

// ✅ Success Dialog
  void _showSuccessDialog(String medicineName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.2 * 255).toInt()),
      // Background dimming
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // ✅ Blur Effect
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎉 Header with Gradient Background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(
                  child: Text(
                    "🎉 Success!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Success Icon
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 12),

              // 💊 Success Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "You have successfully purchased $medicineName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Raleway',
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🆗 OK Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                // Add spacing around the button
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF448AFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(Map<String, dynamic> medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Transparent for Glassmorphism effect
      builder: (context) => Stack(
        children: [
          // Blurred Background Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withAlpha((0.2 * 255).toInt()), // 🔹 Fixed
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.85,
            minChildSize: 0.3,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: controller,
                children: [
                  Hero(
                    tag: 'medicine-${medicine['name']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        medicine['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    medicine['name'],
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Raleway'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "⭐ ${medicine['points']} Points",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Raleway'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _redeemReward(medicine['points'], medicine['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Redeem Now",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Raleway'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPointsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.4, // 40% of screen height
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌟 Animated Star Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.shade100,
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 60),
              ),

              const SizedBox(height: 20),

              // 🎉 Points Message
              Text(
                "⭐ You have $_userPoints points!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Raleway',
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // 💡 Encouraging Message
              const Text(
                "Keep earning and redeem exciting rewards!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Raleway',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // 🚀 Close Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  "Got it!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF4),
      appBar: AppBar(
        title: const Text(
          "🎁 Rewards Shop",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            fontFamily: 'Raleway',
          ),
        ),
        centerTitle: true,
        elevation: 0,
        // 🟡 Add GestureDetector to make the points clickable
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: _showPointsPopup,
              // 👈 Calls the popup function when tapped
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  "⭐ $_userPoints Points",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontFamily: 'Raleway'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            var medicine = medicines[index];
            return _buildMedicineCard(medicine);
          },
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return GestureDetector(
      onTap: () => _showMedicineDetails(medicine),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(medicine['image'],
                  height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(medicine['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway')),
                  const SizedBox(height: 6),
                  Text("⭐ ${medicine['points']} Points",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Raleway')),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showMedicineDetails(medicine),
                    // Open bottom sheet
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    child: const Text(
                      "Buy",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
