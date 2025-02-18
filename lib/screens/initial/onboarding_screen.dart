import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "image": "assets/images/driving_analysis.jpeg",
      "icon": Icons.analytics_outlined,
      "title": "Smart Drive Analysis",
      "description": "Get real-time insights into your driving patterns and receive personalized feedback to improve safety.",
      "gradient": [Color(0xFF6C63FF), Color(0xFF3B38B3)],
      "accent": Color(0xFF8A84FF),
    },
    {
      "image": "assets/images/emergency_alert.jpeg",
      "icon": Icons.notification_important_outlined,
      "title": "Instant SOS Alerts",
      "description": "One-tap emergency alerts share your real-time location with trusted contacts when you need help.",
      "gradient": [Color(0xFFFF6B6B), Color(0xFFB32B2B)],
      "accent": Color(0xFFFF8F8F),
    },
    {
      "image": "assets/images/virtual_training.jpeg",
      "icon": Icons.car_crash_outlined,
      "title": "Virtual Training",
      "description": "Practice safe driving in our realistic simulator and master your skills with instant feedback.",
      "gradient": [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      "accent": Color(0xFF81C784),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _startAutoSlide();
    _animateContent();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  void _animateContent() {
    _cardAnimationController.forward();
    _textAnimationController.forward();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < _onboardingData.length - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _cardAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _onboardingData[_currentPage]["gradient"],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _onboardingData[_currentPage]["accent"].withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _onboardingData[_currentPage]["accent"].withOpacity(0.2),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _cardAnimationController.reset();
                        _textAnimationController.reset();
                        _animateContent();
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return _buildPage(index);
                    },
                  ),
                ),
                _buildNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image card with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.2, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _cardAnimationController,
              curve: Curves.easeOutCubic,
            )),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      _onboardingData[index]["image"],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Icon
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _onboardingData[index]["icon"],
                        color: _onboardingData[index]["gradient"][0],
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),
          // Text content with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _textAnimationController,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: _textAnimationController,
              child: Column(
                children: [
                  Text(
                    _onboardingData[index]["title"],
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _onboardingData[index]["description"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
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

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            child: Text(
              "Skip",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Page indicators
          Row(
            children: List.generate(
              _onboardingData.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_currentPage == index ? 1 : 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Next/Get Started button
          TextButton(
            onPressed: () {
              if (_currentPage == _onboardingData.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              } else {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              _currentPage == _onboardingData.length - 1 ? "Get Started" : "Next",
              style: TextStyle(
                color: _onboardingData[_currentPage]["gradient"][0],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}