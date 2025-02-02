import 'package:algorithm_avengers_ves_final/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import "signup_screen.dart";
import 'package:firebase_auth/firebase_auth.dart';
// import "home_page.dart";

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true; // This controls password visibility
  bool _isLoading = false;
  TextEditingController _emailController =
      TextEditingController(); // Controller for email TextField
  TextEditingController _passwordController =
      TextEditingController(); // Controller for password TextField
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController
        .dispose(); // Dispose of the controller to avoid memory leaks
    _passwordController.dispose();
    super.dispose();
  }

  void _showCreateAccountPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create an Account'),
          content: const Text(
              'It seems you don\'t have an account. Would you like to create one?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUpScreen()), // Redirect to Sign-Up
                );
              },
              child: const Text('Create Account'),
            ),
          ],
        );
      },
    );
  }

// Google sign-in function
  Future<void> _handleGoogleSignIn() async {
    try {
      // Ensure previous account session is signed out
      await _googleSignIn.signOut();

      // Attempt to disconnect the account and handle potential errors gracefully
      try {
        await _googleSignIn.disconnect();
      } catch (error) {
        print('Failed to disconnect: $error');
      }

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleAuth =
            await account.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with the credential
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print('User signed in: ${user.uid}');
          print('User name: ${user.displayName}');
          print('User email: ${user.email}');

          // Check if the user is new or existing
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            // If the user is new, show prompt to create a new account
            _showCreateAccountPrompt();
          } else {
            // If the user is existing, navigate directly to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userName: user.displayName ?? "User",
                  // Pass the user name dynamically
                  email: user.email ?? "No email", // Pass the email dynamically
                ),
              ),
            );
          }
        }
      }
    } catch (error) {
      print('Google sign-in error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $error')),
      );
    }
  }

  // // Facebook sign-in function
  // Future<void> _handleFacebookSignIn() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       final AccessToken accessToken = result.accessToken!;
  //       final credential = FacebookAuthProvider.credential(accessToken.token);
  //       await _auth.signInWithCredential(credential);
  //       // Redirect to another screen
  //     } else {
  //       print('Facebook sign-in error: ${result.message}');
  //     }
  //   } catch (error) {
  //     print('Facebook sign-in error: $error');
  //   }
  // }

  // Email/Password sign-in function
  Future<void> _handleEmailSignIn() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = userCredential.user;
      if (user != null) {
        print('User signed in: ${user.uid}');
        // Navigate to another screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: user.displayName ?? "User",
              // Pass the user name dynamically
              email: user.email ?? "No email", // Pass the email dynamically
            ),
          ),
        ); // Replace with your home route
      }
    } catch (e) {
      print('Email sign-in error: $e');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after the process
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title: "Login here"
                const Text(
                  'Login here',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color:Colors.blueAccent,
                    //color: Color(0xFF1F41BB),
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle: "Welcome back, you've been missed!"
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome back, you've",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      "been missed!",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    prefixIcon:
                        const Icon(Icons.email, color: Colors.blueAccent),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.blueAccent),
                      onPressed: () {
                        setState(() {
                          _emailController.clear();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.blueAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password logic here
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Sign in',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 20),

                // Create new account
                GestureDetector(
                  onTap: () {
                    // Handle navigation to register screen
                  },
                  child: const Text(
                    'Create new account',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF494949),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Or continue with
                const Text(
                  'Or continue with',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),

                // Social Login Icons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _handleGoogleSignIn,
                        child: Image.asset(
                          'assets/images/google_new.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.facebook),
                        iconSize: 36,
                        color: Colors.blue,
                        onPressed: () {},
                        // onPressed: _handleFacebookSignIn,
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.apple),
                        iconSize: 36,
                        color: Colors.black,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
