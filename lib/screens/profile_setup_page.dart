import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userId;

  const ProfileSetupScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carCompanyController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  String? _selectedCarModel;
  bool _isLoading = true;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _imageUrl;

  final List<String> _carModels = ["Model S", "Model 3", "Model X", "Model Y"];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _imageUrl = docSnapshot['profilePhotoUrl'];
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Convert image to Base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Store Base64 image in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profilePhotoBase64': base64Image,
      });

      setState(() {
        _imageUrl = base64Image; // Store it for display
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;
      await _uploadImage(File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? "";
        _emailController.text = user.email ?? "";

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            setState(() {
              _nameController.text = data['name'] ?? "";
              _phoneController.text = data['phone'] ?? "";
              _carCompanyController.text = data['carCompany'] ?? "";
              _selectedCarModel = data['carModel'];
              _carNumberController.text = data['carNumber'] ?? "";
            });
          }
        }
      }
    } catch (e) {
      _showError("Error fetching user details: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'carCompany': _carCompanyController.text.trim(),
        'carModel': _selectedCarModel,
        'carNumber': _carNumberController.text.trim(),
        'userId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile saved successfully!"),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            userName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            // phone: _phoneController.text.trim(),
            // carCompany: _carCompanyController.text.trim(),
            // carModel: _selectedCarModel ?? "",
            // carNumber: _carNumberController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      _showError("Error saving profile: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blueAccent,
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profile Setup')
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blueAccent,
                      Colors.blueAccent.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileAvatar(),
                    const SizedBox(height: 32),
                    ..._buildFormFields(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ]
                      .animate(interval: 50.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: _isUploading
              ? const CircularProgressIndicator()
              : _imageUrl != null
              ? ClipOval(
            child: Image.network(
              _imageUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person_outline, size: 50, color: Colors.blueAccent),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          )
              : const Icon(Icons.person_outline, size: 50, color: Colors.blueAccent),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _isUploading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildTextField(
        controller: _nameController,
        label: 'Full Name',
        prefixIcon: Icons.person_outline,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your name';
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _emailController,
        label: 'Email Address',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email';
          if (!value!.contains('@')) return 'Please enter a valid email';
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _passwordController,
        label: 'Password',
        prefixIcon: Icons.lock_outline,
        obscureText: true,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter a password';
          if (value!.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _phoneController,
        label: 'Phone Number',
        prefixIcon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your phone number';
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _carCompanyController,
        label: 'Car Manufacturing Company',
        prefixIcon: Icons.car_repair,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter car company';
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildDropdownField(),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _carNumberController,
        label: 'Car Number',
        prefixIcon: Icons.numbers,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter car number';
          return null;
        },
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCarModel,
      decoration: InputDecoration(
        labelText: 'Car Model',
        prefixIcon: const Icon(Icons.directions_car),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blueAccent,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: _carModels
          .map((model) => DropdownMenuItem(
        value: model,
        child: Text(model),
      ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedCarModel = value);
      },
      validator: (value) {
        if (value == null) return 'Please select a car model';
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveProfile,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      child: _isSaving
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Text(
        'Save Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}