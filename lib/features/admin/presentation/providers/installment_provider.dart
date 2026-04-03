import 'package:flutter/material.dart';
import '../../data/repositories/installment_repository.dart';
import '../../data/models/installment_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InstallmentProvider extends ChangeNotifier {
  final UpcomingInstallmentRepository repository;

  InstallmentProvider({required this.repository});

  List<UpcomingInstallmentModel> _upcomingInstallments = [];
  bool _isLoading = false;
  String? _error;

  List<UpcomingInstallmentModel> get upcomingInstallments => _upcomingInstallments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUpcomingInstallments({String? advisorCode}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _upcomingInstallments = await repository.getUpcomingInstallments(advisorCode: advisorCode);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsPaid(int dealId, int index) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await repository.markInstallmentAsPaid(dealId, index);
      if (success) {
        // Refresh the list to reflect updates
        await fetchUpcomingInstallments();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadInvoice(UpcomingInstallmentModel installment) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(installment.installmentDate));
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('PRARAMBH INFRA - INVOICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    pw.Text('Ref: #INV-${installment.dealId}-${installment.installmentIndex}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(installment.clientName),
                      pw.Text(installment.clientNumber),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: $dateStr'),
                      pw.Text('Status: ${installment.installmentStatus}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${installment.projectName ?? "Property Installment"}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${installment.unitNumber ?? "N/A"}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(amountFormatter.format(double.tryParse(installment.installmentAmount) ?? 0))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Amount: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text(amountFormatter.format(double.tryParse(installment.installmentAmount) ?? 0), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 100),
              pw.Divider(),
              pw.Center(child: pw.Text('Thank you for choosing Prarambh Infra', style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
            ],
          );
        },
      ),
    );

    // Save/Print the PDF document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${installment.dealId}_${installment.installmentIndex}.pdf',
    );
  }
}
