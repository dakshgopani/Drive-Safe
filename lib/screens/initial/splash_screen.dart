import 'package:algorithm_avengers_ves_final/screens/initial/onboarding_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate loading time

    // Check Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: user.displayName ?? 'User',
            email: user.email ?? 'No Email',
          ),
        ),
      );
    } else {
      // User is not logged in, check SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      if (isFirstLaunch) {
        // First-time user, show onboarding
        prefs.setBool('isFirstLaunch', false); // Mark as completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      } else {
        // Show Welcome/Login Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 20),
            const Text(
              'DriveSafe',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Drive Safe, Drive Smart',
              style: TextStyle(
                color: Color.fromARGB(179, 3, 36, 50),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Color.fromARGB(255, 137, 190, 197),
                color: Color.fromARGB(179, 11, 81, 110),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
