import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../services/email_service.dart';
import '../../../services/pdf_service.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> policy;
  final String ownerName;
  final String vehicleNumber;
  final String email;

  CheckoutPage({
    required this.policy,
    required this.ownerName,
    required this.vehicleNumber,
    required this.email,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = true);
    
    PdfService.generatePdf(
      widget.policy, 
      widget.ownerName, 
      widget.vehicleNumber,
      widget.email
    ).then((file) {
      EmailService.sendEmail(widget.email, file);
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(
            Icons.check_circle, 
            color: Colors.green, 
            size: 80,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Policy document sent to ${widget.email}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Failed!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_BM4Uum7jvmrFBX',
      'amount': widget.policy['price'] * 100,
      'name': 'Policy Checkout',
      'description': widget.policy['name'],
      'prefill': {'email': widget.email},
    };

    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Confirm Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Policy Summary Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        widget.policy['name'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Policy Price:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₹${widget.policy['price']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Owner Name:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.ownerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vehicle Number:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.vehicleNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Payment Button
              _isProcessing 
                ? const CircularProgressIndicator(color: Colors.blueAccent)
                : ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      'Pay Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _startPayment,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}