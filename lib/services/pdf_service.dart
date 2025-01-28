import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> generatePdf(
      Map<String, dynamic> policy, String ownerName, String vehicleNumber, String email) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Padding(
          padding: pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Insurance Policy Confirmation",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Text("Thank you for purchasing your policy. Below are your details:"),
              pw.Divider(),
              pw.SizedBox(height: 8),

              _buildDetailRow("Email", email),
              _buildDetailRow("Owner Name", ownerName),
              _buildDetailRow("Vehicle Number", vehicleNumber),
              _buildDetailRow("Policy Name", policy['name']),
              _buildDetailRow("Policy Price", "₹${policy['price']}"),

              pw.SizedBox(height: 16),
              pw.Text(
                "Please keep this document safe for future reference.",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/policy_confirmation.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(
            "$label: ",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value),
        ],
      ),
    );
  }
}
