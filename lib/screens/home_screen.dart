  import 'package:algorithm_avengers_ves_final/screens/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './profile_screen.dart';
import './map_screen.dart';
import '../widgets/custom_drawer.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String email;

  const HomeScreen({super.key, required this.userName, required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String uniqueId = "Fetching...";
  bool isSpeedingMode = false;
  final TextEditingController _destinationController = TextEditingController();
  bool _isNavigating = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _currentSpeed = "65";
  String _driveTime = "1.5";
  String _distance = "42";

  @override
  void initState() {
    super.initState();
    _fetchUniqueId();
    _startLocationUpdates();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentSpeed = (60 + DateTime.now().second % 20).toString();
          _driveTime = ((DateTime.now().minute % 5) + 1).toString();
          _distance = (40 + DateTime.now().minute % 30).toString();
        });
        _startLocationUpdates();
      }
    });
  }

  Future<void> _fetchUniqueId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            uniqueId = userDoc.id;
          });
        }
      }
    } catch (e) {
      print("Error fetching UID: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(
        userName: widget.userName,
        email: widget.email,
        onSignOut: _signOut,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Positioned.fill(child: const LocationScreen()),
            
            _buildStatusBar(),
            _buildTopBar(),
            _buildDrivingStats(),
            _buildBottomControls(),
            // if (!_isNavigating) _buildNavigationFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).padding.top,
      child: Container(color: Colors.black.withOpacity(0.3)),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration:BoxDecoration(
        color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
                color: Colors.blueAccent,
              ),
            ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Handle search tap
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      const Text(
                        "Search",
                        style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildQuickActionButton(
              icon: Icons.person_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: widget.userName,
                    email: widget.email,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDrivingStats() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: MediaQuery.of(context).padding.top + (_isNavigating ? 80 : 100),
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  _isNavigating ? "Navigation Active" : "Today's Drive",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.speed,
                  value: _currentSpeed,
                  unit: "km/h",
                  label: "Current Speed",
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  value: _driveTime,
                  unit: "hrs",
                  label: "Drive Time",
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.route,
                  value: _distance,
                  unit: "km",
                  label: "Distance",
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (!_isNavigating) _buildModeToggle(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.car_crash_outlined,
                  label: "SOS Alert",
                  color: Colors.red,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.mic,
                  label: "Record Drive",
                  color: Colors.blueAccent,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildNavigationFab() {
  //   return Positioned(
  //     right: 16,
  //     bottom: 180,
  //     child: FloatingActionButton.extended(
  //       onPressed: (){Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => MapScreen()),
  //             );},
  //       backgroundColor: Colors.blueAccent,
  //       icon: const Icon(Icons.navigation),
  //       label: const Text("Navigate"),
  //     ),
  //   );
  // }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isNavigating ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            _isNavigating ? Icons.navigation : Icons.circle,
            color: _isNavigating ? Colors.blue : Colors.green,
            size: 8,
          ),
          const SizedBox(width: 4),
          Text(
            _isNavigating ? "Navigating" : "Active",
            style: TextStyle(
              color: _isNavigating ? Colors.blue[700] : Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSpeedingMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isSpeedingMode ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  "Normal Mode",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !isSpeedingMode ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSpeedingMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSpeedingMode ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  "Speed Alert",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSpeedingMode ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            if (badge != null)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " $unit",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}