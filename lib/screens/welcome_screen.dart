import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLoadingLogin = false; // To track loading state of Login button
  bool isLoadingRegister = false; // To track loading state of Register button

  void _handleLogin() async {
    setState(() {
      isLoadingLogin = true; // Start loading
    });

    // Simulate a delay for the login process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoadingLogin = false; // Stop loading
    });

    // Navigate to login screen
    Navigator.pushNamed(context, '/login');
  }

  void _handleRegister() async {
    setState(() {
      isLoadingRegister = true; // Start loading
    });

    // Simulate a delay for the registration process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoadingRegister = false; // Stop loading
    });

    // Navigate to register screen
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Positioned ellipse images at the top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFFF8F9FF),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/images/Ellipse_1.png',
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFFF8F9FF),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/images/Ellipse_2.png',
              ),
            ),
          ),

          // Main content of the screen
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Illustration
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 250,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'assets/images/home_img.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title with highlighted word
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                            // color: Color(0xFF1F41BB),
                            color:Colors.blueAccent,
                            fontFamily: 'Poppins',
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'Smart Driving\n'),
                            TextSpan(
                              text: '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: 'Real-Time Insights'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Padding(
                        padding: const EdgeInsets.only(top: 23.0),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                              color: Color(0xFF000000),
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text:
                                'Experience Real-Time Driving Behavior Analysis \n',
                              ),
                              TextSpan(text: 'at Your Fingertips'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Buttons with loading indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Login Button
                          ElevatedButton(
                            onPressed: isLoadingLogin ? null : _handleLogin,
                            // Disable button when loading
                            child: isLoadingLogin
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: const Color(0xFF1F41BB),
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Register Button
                          OutlinedButton(
                            onPressed:
                            isLoadingRegister ? null : _handleRegister,
                            // Disable button when loading
                            child: isLoadingRegister
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF1F41BB),
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Register',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
