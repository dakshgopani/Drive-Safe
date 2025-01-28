import 'package:algorithm_avengers_ves_final/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupPage extends StatefulWidget {
  final String userId;

  ProfileSetupPage({required this.userId});

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carCompanyController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  String? _selectedCarModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? "";
        _emailController.text = user.email ?? "";

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            _nameController.text = data['name'] ?? "";
            _phoneController.text = data['phone'] ?? "";
            _carCompanyController.text = data['carCompany'] ?? "";
            _selectedCarModel = data['carModel'] ?? null;
            _carNumberController.text = data['carNumber'] ?? "";
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user details: $e")),
      );
      print("Error fetching user details: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final carCompany = _carCompanyController.text.trim();
    final carNumber = _carNumberController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty || carCompany.isEmpty || carNumber.isEmpty || _selectedCarModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields")),
      );
      print("Validation failed: Some fields are empty");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user logged in")),
        );
        print("Error: No user logged in");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'carCompany': carCompany,
        'carModel': _selectedCarModel,
        'carNumber': carNumber,
        'userId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
      print("Profile saved successfully");

      // After saving the profile, navigate to the Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(
          userName: user.displayName ?? "User",
          // Pass the user name dynamically
          email: user.email ?? "No email",
        )), // Ensure to import the correct HomeScreen
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
      print("Error saving profile: $e");
    }
  }


  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueGrey)),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCarModel,
      decoration: InputDecoration(
        labelText: "Car Model",
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueGrey)),
      ),
      items: ["Model A", "Model B", "Model C"] // Replace with actual models
          .map((model) => DropdownMenuItem(value: model, child: Text(model)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCarModel = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildTextField(_nameController, "Full Name"),
              const SizedBox(height: 20),
              _buildTextField(_emailController, "Email Address", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, "Create Password", keyboardType: TextInputType.visiblePassword, obscureText: true),
              const SizedBox(height: 20),
              _buildTextField(_phoneController, "Phone Number", keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField(_carCompanyController, "Car Manufacturing Company"),
              const SizedBox(height: 20),
              _buildDropdownField(),
              const SizedBox(height: 20),
              _buildTextField(_carNumberController, "Car Number"),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Color(0xFF1F41BB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
