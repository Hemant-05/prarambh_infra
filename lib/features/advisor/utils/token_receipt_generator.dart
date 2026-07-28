import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/utils/file_download_helper.dart';

class TokenReceiptGenerator {
  static Future<File?> generateAndSaveReceipt({
    required String customerName,
    required String mobileNumber,
    required String projectName,
    required String unitNumber,
    required String dimensions,
    required String buildUpArea,
    required String tokenAmount,
    required String modeOfPayment,
    required String dueDate,
    required String status,
    required String tokenId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'TOKEN RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Token ID: #$tokenId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 30),
                
                // Customer Details
                pw.Text('CUSTOMER DETAILS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                _buildRow('Customer Name:', customerName),
                _buildRow('MOBILE NUMBER:', mobileNumber),
                pw.SizedBox(height: 20),
                
                // Property Details
                pw.Text('PROPERTY DETAILS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                _buildRow('Project Name:', projectName),
                _buildRow('Unit/Plot Number:', unitNumber),
                _buildRow('PLOT DIMENSION:', dimensions),
                _buildRow('BUILD UP AREA/ sq.feet:', buildUpArea),
                pw.SizedBox(height: 20),
                
                // Payment Details
                pw.Text('PAYMENT DETAILS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                _buildRow('Token Amount:', 'INR $tokenAmount'),
                _buildRow('Mode of Payment:', modeOfPayment),
                _buildRow('Due Date:', dueDate),
                _buildRow('Status:', status.toUpperCase()),
                
                pw.Spacer(),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'This is a system generated receipt and does not require a signature.',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      String? downloadPath;
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          downloadPath = directory.path;
        } else {
          downloadPath = (await getExternalStorageDirectory())?.path;
        }
      } else {
        downloadPath = (await getApplicationDocumentsDirectory()).path;
      }
      
      if (downloadPath == null) return null;
      
      final prarambhDir = Directory(p.join(downloadPath, "Prarambh_Infra"));
      if (!await prarambhDir.exists()) {
        await prarambhDir.create(recursive: true);
      }
      
      final fileName = 'Receipt_$tokenId.pdf';
      final savePath = p.join(prarambhDir.path, fileName);
      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColors.grey800, fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
