import 'package:algorithm_avengers_ves_final/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_screen.dart';
import 'onboarding_screen.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start animations and navigation
    _animationController.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate loading time

    // Check Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MapScreen(
            userId: user.uid ?? "No Id",
            userName: user.displayName ?? 'User',
            email: user.email ?? 'No Email',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        // Show Welcome/Login Screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blueAccent.shade100,
                  Colors.white,
                ],
              ),
            ),
          ).animate()
          .fadeIn(duration: const Duration(milliseconds: 1000)),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Animated Logo
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ).animate()
                .fadeIn(duration: const Duration(milliseconds: 800))
                .shake(
                  duration: const Duration(milliseconds: 800),
                  hz: 3,
                  rotation: 0.05,
                ),

                const SizedBox(height: 20),

                // Animated Title
                SlideTransition(
                  position: _textSlideAnimation,
                  child: Text(
                    'DriveSafe',
                    style: GoogleFonts.cabin(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueAccent.shade700,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black12,
                          offset: Offset(3.0, 3.0),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                .fade(duration: const Duration(milliseconds: 800))
                .slideY(
                  begin: 0.5,
                  end: 0,
                  duration: const Duration(milliseconds: 600),
                ),

                const SizedBox(height: 15),

                // Animated Subtitle
                SlideTransition(
                  position: _textSlideAnimation,
                  child: Text(
                    'Drive Safe, Drive Smart',
                    style: GoogleFonts.cabin(
                      color: Colors.blueAccent.shade200,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate()
                .fade(duration: const Duration(milliseconds: 1000))
                .slideY(
                  begin: 0.5,
                  end: 0,
                  duration: const Duration(milliseconds: 800),
                ),

                const SizedBox(height: 70),

                // Animated Progress Indicator
                SizedBox(
                  width: 250,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.blueAccent.shade100.withOpacity(0.3),
                    color: Colors.blueAccent.shade700,
                    minHeight: 6,
                  ),
                ).animate()
                .fade(duration: const Duration(milliseconds: 1200))
                .scale(
                  begin:Offset(0.5, 0.5),
                  end: Offset(1, 1),
                  duration: const Duration(milliseconds: 800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}