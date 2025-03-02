import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:algorithm_avengers_ves_final/services/email_service.dart';
import 'package:algorithm_avengers_ves_final/services/pdf_service.dart';

class InsurancePolicy {
  final String policyId;
  final String name;
  final String category;
  final double monthlyPremium;
  final double coverageAmount;
  final double deductible;
  final List<String> benefits;
  final double minScore;

  InsurancePolicy({
    required this.policyId,
    required this.name,
    required this.category,
    required this.monthlyPremium,
    required this.coverageAmount,
    required this.deductible,
    required this.benefits,
    required this.minScore,
  });
}

class PolicyCalculatorScreen extends StatefulWidget {
  final double drivingScore;

  PolicyCalculatorScreen({required this.drivingScore});

  @override
  _PolicyCalculatorScreenState createState() => _PolicyCalculatorScreenState();
}

class _PolicyCalculatorScreenState extends State<PolicyCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  late Razorpay _razorpay;

  List<InsurancePolicy> availablePolicies = [];
  InsurancePolicy? recommendedPolicy;
  String? userEmail;
  String? userName;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchUserEmail();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _fetchUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please log in to proceed')));
    }
  }

  List<InsurancePolicy> getPolicyCatalog() =>
      [
        InsurancePolicy(
            policyId: 'PLT-001',
            name: 'Platinum Elite',
            category: 'Premium',
            monthlyPremium: 2500.0,
            coverageAmount: 250000.0,
            deductible: 0.0,
            benefits: [
              'Full Coverage',
              'Zero Deductible',
              'Rental Car',
              'Roadside',
              'Personal Injury'
            ],
            minScore: 95),
        InsurancePolicy(
            policyId: 'PLT-002',
            name: 'Platinum Plus',
            category: 'Premium',
            monthlyPremium: 2200.0,
            coverageAmount: 200000.0,
            deductible: 250.0,
            benefits: [
              'Comprehensive',
              'Rental Car',
              'Roadside',
              'Medical Payments',
              'Theft Protection'
            ],
            minScore: 90),
        InsurancePolicy(
            policyId: 'GLD-001',
            name: 'Gold Protection',
            category: 'Premium',
            monthlyPremium: 1800.0,
            coverageAmount: 180000.0,
            deductible: 500.0,
            benefits: [
              'Comprehensive',
              'Rental Car',
              'Roadside',
              'Medical Payments'
            ],
            minScore: 85),
        InsurancePolicy(
            policyId: 'GLD-002',
            name: 'Gold Essential',
            category: 'Premium',
            monthlyPremium: 1500.0,
            coverageAmount: 150000.0,
            deductible: 750.0,
            benefits: ['Collision', 'Liability', 'Roadside', 'Minor Repairs'],
            minScore: 80),
        InsurancePolicy(
            policyId: 'SLV-001',
            name: 'Silver Coverage',
            category: 'Standard',
            monthlyPremium: 1200.0,
            coverageAmount: 100000.0,
            deductible: 1000.0,
            benefits: ['Collision', 'Liability', 'Roadside Assistance'],
            minScore: 70),
        InsurancePolicy(
            policyId: 'SLV-002',
            name: 'Silver Select',
            category: 'Standard',
            monthlyPremium: 1000.0,
            coverageAmount: 80000.0,
            deductible: 1200.0,
            benefits: ['Basic Liability', 'Collision', 'Weather Damage'],
            minScore: 65),
        InsurancePolicy(
            policyId: 'BRZ-001',
            name: 'Bronze Basic',
            category: 'Standard',
            monthlyPremium: 8000.0,
            coverageAmount: 50000.0,
            deductible: 2000.0,
            benefits: ['Basic Liability', 'Collision'],
            minScore: 50),
        InsurancePolicy(
            policyId: 'BRZ-002',
            name: 'Bronze Shield',
            category: 'Standard',
            monthlyPremium: 7000.0,
            coverageAmount: 45000.0,
            deductible: 2500.0,
            benefits: ['Liability', 'Minor Collision'],
            minScore: 45),
        InsurancePolicy(
            policyId: 'ECO-001',
            name: 'Economy Plan',
            category: 'Budget',
            monthlyPremium: 5000.0,
            coverageAmount: 30000.0,
            deductible: 3000.0,
            benefits: ['Minimum Liability', 'Basic Coverage'],
            minScore: 35),
        InsurancePolicy(
            policyId: 'ECO-002',
            name: 'Economy Lite',
            category: 'Budget',
            monthlyPremium: 4500.0,
            coverageAmount: 25000.0,
            deductible: 3500.0,
            benefits: ['Minimum Liability', 'Third-Party Damage'],
            minScore: 30),
        InsurancePolicy(
            policyId: 'LTD-001',
            name: 'Limited Basic',
            category: 'Limited',
            monthlyPremium: 3500.0,
            coverageAmount: 15000.0,
            deductible: 5000.0,
            benefits: ['Minimum Liability'],
            minScore: 25),
        InsurancePolicy(
            policyId: 'LTD-002',
            name: 'Limited Starter',
            category: 'Limited',
            monthlyPremium: 3000.0,
            coverageAmount: 12000.0,
            deductible: 5500.0,
            benefits: ['Basic Liability'],
            minScore: 20),
        InsurancePolicy(
            policyId: 'FAM-001',
            name: 'Family Protector',
            category: 'Special',
            monthlyPremium: 2000.0,
            coverageAmount: 200000.0,
            deductible: 300.0,
            benefits: [
              'Family Coverage',
              'Collision',
              'Roadside',
              'Medical',
              'Rental'
            ],
            minScore: 80),
        InsurancePolicy(
            policyId: 'SEN-001',
            name: 'Senior Safe',
            category: 'Special',
            monthlyPremium: 9000.0,
            coverageAmount: 60000.0,
            deductible: 1500.0,
            benefits: [
              'Liability',
              'Collision',
              'Medical Payments',
              'Senior Discounts'
            ],
            minScore: 60),
        InsurancePolicy(
            policyId: 'YNG-001',
            name: 'Young Driver',
            category: 'Special',
            monthlyPremium: 1100.0,
            coverageAmount: 70000.0,
            deductible: 1800.0,
            benefits: [
              'Liability',
              'Collision',
              'Roadside',
              'Driver Training Discount'
            ],
            minScore: 55),
        InsurancePolicy(
            policyId: 'COM-001',
            name: 'Commuter Plus',
            category: 'Special',
            monthlyPremium: 1300.0,
            coverageAmount: 90000.0,
            deductible: 1000.0,
            benefits: [
              'Daily Commute',
              'Collision',
              'Liability',
              'Public Transport'
            ],
            minScore: 65),
        InsurancePolicy(
            policyId: 'RUR-001',
            name: 'Rural Driver',
            category: 'Special',
            monthlyPremium: 6000.0,
            coverageAmount: 35000.0,
            deductible: 2000.0,
            benefits: ['Rural Roads', 'Liability', 'Animal Collision'],
            minScore: 40),
        InsurancePolicy(
            policyId: 'PRE-001',
            name: 'Premium Lite',
            category: 'Premium',
            monthlyPremium: 1900.0,
            coverageAmount: 160000.0,
            deductible: 600.0,
            benefits: [
              'Comprehensive',
              'Roadside',
              'Rental Car',
              'Glass Coverage'
            ],
            minScore: 88),
        InsurancePolicy(
            policyId: 'STD-001',
            name: 'Standard Plus',
            category: 'Standard',
            monthlyPremium: 9500.0,
            coverageAmount: 75000.0,
            deductible: 1300.0,
            benefits: ['Liability', 'Collision', 'Theft', 'Basic Roadside'],
            minScore: 62),
        InsurancePolicy(
            policyId: 'BGT-001',
            name: 'Budget Plus',
            category: 'Budget',
            monthlyPremium: 5500.0,
            coverageAmount: 40000.0,
            deductible: 2800.0,
            benefits: ['Liability', 'Collision', 'Minor Repairs'],
            minScore: 38),
      ];

  void calculateAndSuggestPolicy() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        userName = _nameController.text;
        final allPolicies = getPolicyCatalog();
        availablePolicies = allPolicies
            .where((policy) => widget.drivingScore >= policy.minScore)
            .toList();
        recommendedPolicy = availablePolicies.isNotEmpty
            ? availablePolicies.first
            : allPolicies.last;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful: ${response.paymentId}')));
    _sendPolicyEmail();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet: ${response.walletName}')));
  }

  void _startPayment(InsurancePolicy policy) {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No email found. Please log in.')));
      return;
    }
    var options = {
      'key': 'rzp_test_BM4Uum7jvmrFBX',
      'amount': (policy.monthlyPremium * 100).toInt(), // Convert INR to paise
      'name': 'Insurance Payment',
      'description': policy.name,
      'prefill': {'contact': '1234567890', 'email': userEmail},
      'currency': 'INR',
    };
    _razorpay.open(options);
  }

  Future<void> _sendPolicyEmail() async {
    if (userEmail == null || userName == null || recommendedPolicy == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No email or policy found. Please try again.')));
      return;
    }

    // Prepare policy data for PdfService
    final policyData = {
      'name': recommendedPolicy!.name,
      'price': recommendedPolicy!.monthlyPremium,
    };

    try {
      // Generate PDF using PdfService
      final pdfFile = await PdfService.generatePdf(
        policyData,
        userName!,
        _vehicleNumberController.text,
        userEmail!,
      );

      // Send email using EmailService
      await EmailService.sendEmail(userEmail!, pdfFile);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Policy sent to $userEmail')));
    } catch (e) {
      print('Error in sending policy email: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send email: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insurance Calculator',
          style: TextStyle(fontWeight: FontWeight.w600,
          color: Colors.white),
        ),
        elevation: 0,
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent.shade700, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How it works',
                              style: TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent)),
                          SizedBox(height: 16),
                          Text(
                              'We calculate policy recommendations based on your driving score and vehicle details. Better scores qualify for premium policies with better rates.'),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Got it'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.withOpacity(0.2), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                            _nameController, 'Full Name', Icons.person),
                        SizedBox(height: 16),
                        _buildTextField(_vehicleNumberController,
                            'Vehicle Number', Icons.directions_car),
                        SizedBox(height: 16),
                        _buildScoreField(),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: calculateAndSuggestPolicy,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calculate),
                                SizedBox(width: 8),
                                Text(
                                  'Calculate Policies',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (recommendedPolicy != null) ...[
                SizedBox(height: 32),
                _buildScoreDisplay(),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Recommended For You',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                PolicyCard(
                  policy: recommendedPolicy!,
                  onPurchase: () => _startPayment(recommendedPolicy!),
                  isRecommended: true,
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Other Available Policies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ...availablePolicies.map((policy) =>
                    PolicyCard(
                        policy: policy,
                        onPurchase: () => _startPayment(policy))),
              ],
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      [TextInputType? type, bool enabled = true]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: type,
      enabled: enabled,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildScoreField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.score, color: Colors.blueAccent),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driving Score',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              SizedBox(height: 4),
              Text(
                widget.drivingScore.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    double score = widget.drivingScore;
    Color scoreColor = Colors.red;
    String scoreText = "Poor";

    if (score >= 90.0) {
      scoreColor = Colors.green;
      scoreText = "Excellent";
    } else if (score >= 70.5) {
      scoreColor = Colors.lightGreen;
      scoreText = "Great";
    } else if (score >= 60.0) {
      scoreColor = Colors.amber;
      scoreText = "Good";
    } else if (score >= 40.5) {
      scoreColor = Colors.orange;
      scoreText = "Average";
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your Driving Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scoreColor.withOpacity(0.7), scoreColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'out of 100',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              scoreText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your driving score affects your premium rates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PolicyCard extends StatelessWidget {
  final InsurancePolicy policy;
  final VoidCallback onPurchase;
  final bool isRecommended;

  const PolicyCard(
      {required this.policy,
        required this.onPurchase,
        this.isRecommended = false});

  Color _getCategoryColor() {
    switch (policy.category) {
      case 'Premium':
        return Colors.blueAccent;
      case 'Standard':
        return Colors.blue;
      case 'Budget':
        return Colors.teal;
      case 'Limited':
        return Colors.grey;
      case 'Special':
        return Colors.purpleAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${policy.name} (${policy.category})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _getCategoryColor(),
                    ),
                  ),
                ),
                if (isRecommended)
                  Chip(
                    label: Text('Recommended'),
                    backgroundColor: Colors.amber[100],
                    labelStyle: TextStyle(color: Colors.amber[900]),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text('Policy ID: ${policy.policyId}',
                style: TextStyle(color: Colors.grey[600])),
            Text(
                'Monthly Premium: ${(policy.monthlyPremium).toStringAsFixed(2)} INR',
                style: TextStyle(fontSize: 16)),
            Text('Coverage: ${policy.coverageAmount.toStringAsFixed(2)} INR',
                style: TextStyle(fontSize: 16)),
            Text('Deductible: ${policy.deductible.toStringAsFixed(2)} INR',
                style: TextStyle(fontSize: 16)),
            Text('Minimum Score: ${policy.minScore}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...policy.benefits.map(
                    (b) => Text('- $b', style: TextStyle(color: Colors.grey[700]))),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onPurchase,
              icon: Icon(Icons.shopping_cart),
              label: Text('Purchase Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getCategoryColor(),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}