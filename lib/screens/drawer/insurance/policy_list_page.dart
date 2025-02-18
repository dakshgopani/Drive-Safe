import 'package:flutter/material.dart';
import 'policy_details_page.dart';

class PolicyListPage extends StatelessWidget {
  final List<Map<String, dynamic>> policies = [
    {'name': 'Comprehensive Cover', 'price': 5000, 'coverage': 'Full'},
    {'name': 'Third-Party Liability', 'price': 3000, 'coverage': 'Third-Party'},
    {'name': 'Personal Accident Cover', 'price': 2000, 'coverage': 'Personal'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Light gradient-like background
      appBar: AppBar(
        title: Text('Available Policies'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: policies.length,
          itemBuilder: (context, index) {
            final policy = policies[index];
            return _buildPolicyCard(context, policy);
          },
        ),
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, Map<String, dynamic> policy) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              policy['name'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Coverage: ${policy['coverage']}",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              "Price: ₹${policy['price']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PolicyDetailsPage(policy),
                    ),
                  );
                },
                child: Text(
                  'Buy Now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
