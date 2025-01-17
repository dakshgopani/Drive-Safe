import 'package:algorithm_avengers_ves_final/app.dart';
import 'package:algorithm_avengers_ves_final/screens/initial/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate loading time
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()), // Replace with your home page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png', // Replace with your logo image path
              width: 350,
              height: 350,
            ),
            SizedBox(height: 20),
            Text(
              'DriveSafe',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(179, 1, 23, 32)
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Drive Safe, Drive Smart',
              style: TextStyle(
                color: Color.fromARGB(179, 3, 36, 50),
                fontSize: 18,
                ),
              textAlign: TextAlign.center,
                
              ),
            SizedBox(height: 70),
            // Loading bar (linear progress indicator)
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: const Color.fromARGB(255, 137, 190, 197),
                color: Color.fromARGB(179, 11, 81, 110), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}