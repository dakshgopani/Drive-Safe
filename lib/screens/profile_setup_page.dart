import 'dart:convert';
import 'dart:io';
import 'package:algorithm_avengers_ves_final/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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
  final String apikey = '5a49871c0cmsh9b15b2793087336p143bd4jsn63eda080b121';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carManufacturingYear = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();

  // Variables for car API integration
  List<String> _carMakes = [];
  List<String> _carModels = [];
  String? _selectedCarMake;
  String? _selectedCarModel;
  bool _isLoadingMakes = false;
  bool _isLoadingModels = false;

  bool _isLoading = true;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchUserProfile();
    _loadCarMakes();
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

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profilePhotoBase64': base64Image,
      });

      setState(() {
        _imageUrl = base64Image;
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
      _showError('Error uploading image: $e');
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
      _showError('Error picking image: $e');
    }
  }

  Future<void> _loadCarMakes() async {
    setState(() => _isLoadingMakes = true);
    try {
      _carMakes = await fetchCarMakes();
      setState(() {});
    } catch (e) {
      _showError("Error loading car makes: $e");
    } finally {
      setState(() => _isLoadingMakes = false);
    }
  }

  Future<void> _loadCarModels() async {
    if (_selectedCarMake == null || _carManufacturingYear.text.isEmpty) return;

    setState(() => _isLoadingModels = true);
    try {
      _carModels = await fetchCarModels(
        year: _carManufacturingYear.text,
        make: _selectedCarMake!,
      );
      setState(() {
        _selectedCarModel = null;
      });
    } catch (e) {
      _showError("Error loading car models: $e");
    } finally {
      setState(() => _isLoadingModels = false);
    }
  }

  static Future<List<String>> fetchCarMakes() async {
    final url = Uri.parse('https://car-data.p.rapidapi.com/cars/makes');
    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-key': '5a49871c0cmsh9b15b2793087336p143bd4jsn63eda080b121', // Replace with your actual API key
        'x-rapidapi-host': 'car-data.p.rapidapi.com',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<String> carMakes = List<String>.from(jsonResponse);
      return carMakes;
    } else {
      throw Exception('Failed to load car makes');
    }
  }

  static Future<List<String>> fetchCarModels({
    required String year,
    required String make,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('https://cars-api10.p.rapidapi.com/models?year=$year&make=$make'),
        headers: {
          "x-rapidapi-key": '5a49871c0cmsh9b15b2793087336p143bd4jsn63eda080b121', // Replace with your actual API key
          "x-rapidapi-host": 'cars-api10.p.rapidapi.com',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> models = jsonResponse['data']['Models'];
        return models.map((model) => model['model_name'] as String).toList();
      } else {
        throw Exception("Failed to load car models. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching car models: $e");
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
              _selectedCarMake = data['carMake'];
              _selectedCarModel = data['carModel'];
              _carNumberController.text = data['carNumber'] ?? "";
              _carManufacturingYear.text = data['carManufacturingYear'] ?? "";

              // Load car models if we have both year and make
              if (_carManufacturingYear.text.isNotEmpty && _selectedCarMake != null) {
                _loadCarModels();
              }
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
        'carMake': _selectedCarMake,
        'carModel': _selectedCarModel,
        'carNumber': _carNumberController.text.trim(),
        'carManufacturingYear': _carManufacturingYear.text.trim(),
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
          builder: (context) => MapScreen(
            userName: _nameController.text.trim(),
            email: _emailController.text.trim(), 
            userId: widget.userId,
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
      return const Scaffold(
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
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: _isUploading
              ? const CircularProgressIndicator()
              : _imageUrl != null
              ? ClipOval(
            child: Image.memory(
              base64Decode(_imageUrl!),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person_outline, size: 50, color: Colors.blueAccent),
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
        controller: _carManufacturingYear,
        label: 'Car Manufacturing Year',
        prefixIcon: Icons.calendar_today,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter manufacturing year';
          if (value!.length != 4) return 'Please enter a valid year';
          final year = int.tryParse(value);
          if (year == null) return 'Please enter a valid year';
          if (year < 1900 || year > DateTime.now().year + 1) {
            return 'Please enter a valid year between 1900 and ${DateTime.now().year + 1}';
          }
          return null;
        },
        onChanged: (value) {
          if (value.length == 4 && _selectedCarMake != null) {
            _loadCarModels();
          }
        },
      ),
      const SizedBox(height: 20),

      _buildCarMakeDropdown(),
      const SizedBox(height: 20),

      _buildCarModelDropdown(),
      const SizedBox(height: 20),

      _buildTextField(
        controller: _carNumberController,
        label: 'Car Number',
        prefixIcon: Icons.numbers,
        textCapitalization: TextCapitalization.characters,
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildCarMakeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCarMake,
      decoration: InputDecoration(
        labelText: 'Car Make',
        prefixIcon: const Icon(Icons.car_repair),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: _carMakes.map((make) => DropdownMenuItem(
        value: make,
        child: Text(make),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCarMake = value;
          _selectedCarModel = null; // Reset model when make changes
        });
        if (value != null && _carManufacturingYear.text.length == 4) {
          _loadCarModels();
        }
      },
      validator: (value) => value == null ? 'Please select a car make' : null,
      isExpanded: true,
      hint: Text(_isLoadingMakes ? 'Loading...' : 'Select Car Make'),
    );
  }

  Widget _buildCarModelDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCarModel,
      decoration: InputDecoration(
        labelText: 'Car Model',
        prefixIcon: const Icon(Icons.directions_car),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: _carModels.map((model) => DropdownMenuItem(
        value: model,
        child: Text(model),
      )).toList(),
      onChanged: _selectedCarMake == null ? null : (value) {
        setState(() => _selectedCarModel = value);
      },
      validator: (value) => value == null ? 'Please select a car model' : null,
      isExpanded: true,
      hint: Text(_isLoadingModels
          ? 'Loading...'
          : _selectedCarMake == null
          ? 'Select a car make first'
          : 'Select Car Model'),
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