import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BusinessPlanScreen extends StatelessWidget {
  const BusinessPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Plan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.asset(
        'assets/docs/business_plan.pdf',
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
