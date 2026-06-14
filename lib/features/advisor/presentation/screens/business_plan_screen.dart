import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessPlanScreen extends StatefulWidget {
  const BusinessPlanScreen({super.key});

  @override
  State<BusinessPlanScreen> createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Business Plan',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        'assets/documents/business_plan.pdf',
        key: _pdfViewerKey,
      ),
    );
  }
}
