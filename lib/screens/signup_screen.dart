import 'package:algorithm_avengers_ves_final/screens/home_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/profile_setup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:mad_practice_one/screens/profile_setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'home_page.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true; // Controls password visibility
  TextEditingController _emailController =
  TextEditingController(); // Email controller
  TextEditingController _passwordController =
  TextEditingController(); // Password controller
  TextEditingController _confirmPasswordController =
  TextEditingController(); // Confirm password controller
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
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

          // Check if the user exists in Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            // User already exists, show message or redirect to HomePage
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text('You already have an account. Redirecting to Home.'),
              ),
            );

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
          } else {
            // New user, navigate to Profile Setup Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSetupScreen(userId: user.uid),
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

  Future<void> _handleSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    try {
      // Register the user with Firebase Auth
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user is new
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          // If the user is new, navigate to Profile Setup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSetupScreen(userId: user.uid),
            ),
          );
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
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          default:
            errorMessage = 'Sign-up failed. Please try again later.';
        }
      } else {
        errorMessage = 'An unknown error occurred.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
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
                // Title: "Create Account"
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  "Create an account so you can explore the \n Pocket-Friendly Road Companion",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
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
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.blueAccent),
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
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
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
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password TextField
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
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
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _handleSignUp,
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),

                // Already have an account
                GestureDetector(
                  onTap: () {
                    // Navigate back to the login screen
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Already have an account',
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
                        onPressed: () {
                          // Facebook Sign-Up logic
                        },
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.apple),
                        iconSize: 36,
                        color: Colors.black,
                        onPressed: () {
                          // Apple Sign-Up logic
                        },
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
