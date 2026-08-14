import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../features/admin/data/models/deal_model.dart';
import 'package:share_plus/share_plus.dart';

class PdfReceiptGenerator {
  static Future<void> generateAndShareReceipt(DealModel deal) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('Prarambh Infra', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text('Booking Receipt', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
              ),
              pw.SizedBox(height: 30),
              
              // Customer Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Customer Name: ${deal.clientName}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Property Details
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Project Name: ${deal.projectName ?? "N/A"}'),
                    pw.SizedBox(height: 4),
                    pw.Text('Plot/Unit No: ${deal.unitNumber ?? "N/A"}'),
                    pw.SizedBox(height: 4),
                    pw.Text('Size: N/A'),
                    pw.SizedBox(height: 4),
                    pw.Text('Net Rate: N/A'),
                    pw.SizedBox(height: 4),
                    pw.Text('Total Value: ${deal.paymentAmount ?? "0"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]
                )
              ),
              pw.SizedBox(height: 20),

              // Token Section
              pw.Text('Token Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Amount', 'Date', 'Mode', 'Status'],
                data: [
                  [
                    deal.tokenAmount ?? "0",
                    deal.tokenDate ?? "N/A",
                    (deal.tokenPaymentMode ?? "N/A").toUpperCase(),
                    'Received'
                  ]
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellAlignment: pw.Alignment.center,
              ),
              pw.SizedBox(height: 20),

              // Installment Section
              if (deal.installments.isNotEmpty) ...[
                pw.Text('Installment Plan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  context: context,
                  headers: ['Amount', 'Due Date', 'Mode', 'Received Date', 'Status'],
                  data: deal.installments.map((inst) {
                    return [
                      '${inst['amount'] ?? "0"}',
                      inst['date'] ?? "N/A",
                      (inst['payment_mode'] ?? "-").toUpperCase(),
                      inst['received_date'] ?? "-",
                      inst['status'] ?? "Pending"
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  cellAlignment: pw.Alignment.center,
                ),
              ]
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_${deal.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // Share the generated PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Booking Receipt for ${deal.clientName}');
  }
}
