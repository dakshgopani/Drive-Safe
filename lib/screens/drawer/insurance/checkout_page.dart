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

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    PdfService.generatePdf(widget.policy, widget.ownerName, widget.vehicleNumber,widget.email).then((file) {
      EmailService.sendEmail(widget.email, file);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Successful!')));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed!')));
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
      appBar: AppBar(title: Text('Checkout')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startPayment,
          child: Text('Pay ₹${widget.policy['price']}'),
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