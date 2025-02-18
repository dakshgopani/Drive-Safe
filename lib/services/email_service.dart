import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendEmail(String email, File pdfFile) async {
    // SMTP server settings
    String username = 'rudraparmar1309@gmail.com';
    String password = 'rouu lbui djxo upst'; // App password if using Gmail

    final smtpServer = gmail(username, password);

    // Create the email
    final message = Message()
      ..from = Address(username, 'Drive Safe App')
      ..recipients.add(email)
      ..subject = 'Insurance Policy'
      ..text = 'Your insurance policy is attached.'
      ..attachments.add(FileAttachment(pdfFile));

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Failed to send email: $e');
    }
  }
}