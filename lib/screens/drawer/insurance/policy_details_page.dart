import 'package:flutter/material.dart';
import 'checkout_page.dart';

class PolicyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> policy;
  PolicyDetailsPage(this.policy);

  @override
  _PolicyDetailsPageState createState() => _PolicyDetailsPageState();
}

class _PolicyDetailsPageState extends State<PolicyDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String ownerName = '';
  String vehicleNumber = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background
      appBar: AppBar(
        title: Text('Enter Details'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Policy Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      label: "Owner Name",
                      icon: Icons.person,
                      onSave: (value) => ownerName = value!,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      label: "Vehicle Number",
                      icon: Icons.directions_car,
                      onSave: (value) => vehicleNumber = value!,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      label: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      onSave: (value) => email = value!,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  policy: widget.policy,
                                  ownerName: ownerName,
                                  vehicleNumber: vehicleNumber,
                                  email: email,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Proceed to Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required Function(String?) onSave,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      onSaved: onSave,
    );
  }
}
