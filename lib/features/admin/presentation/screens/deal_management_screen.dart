import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/deal_model.dart';
import '../providers/admin_deal_provider.dart';

class DealManagementScreen extends StatefulWidget {
  final DealModel deal;
  final bool isReraApproved; // Check property model before passing this

  const DealManagementScreen({super.key, required this.deal, this.isReraApproved = false});

  @override
  State<DealManagementScreen> createState() => _DealManagementScreenState();
}

class _DealManagementScreenState extends State<DealManagementScreen> {
  final _totalAmountCtrl = TextEditingController();
  String _selectedPlan = 'Select Plan';
  List<Map<String, dynamic>> _installments = [];

  // EXACT Plans Requested
  final List<String> _plans = [
    'Select Plan',
    '100% Upfront (RERA Approved)',
    '50% - 50%',
    '25% - 75%',
    '33% - 33% - 34%',
    '25% - 25% - 50%',
    '25% - 25% - 25% - 25%',
    '20% - 20% - 20% - 20% - 20%'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isReraApproved) {
      _selectedPlan = '100% Upfront (RERA Approved)';
    }
  }

  void _generateInstallments() {
    double total = double.tryParse(_totalAmountCtrl.text) ?? 0;
    if (total <= 0 || _selectedPlan == 'Select Plan') return;

    List<double> percentages = [];
    if (_selectedPlan.contains('100%')) percentages = [1.0];
    else if (_selectedPlan == '50% - 50%') percentages = [0.5, 0.5];
    else if (_selectedPlan == '25% - 75%') percentages = [0.25, 0.75];
    else if (_selectedPlan == '33% - 33% - 34%') percentages = [0.33, 0.33, 0.34];
    else if (_selectedPlan == '25% - 25% - 50%') percentages = [0.25, 0.25, 0.50];
    else if (_selectedPlan == '25% - 25% - 25% - 25%') percentages = [0.25, 0.25, 0.25, 0.25];
    else if (_selectedPlan.contains('20%')) percentages = [0.2, 0.2, 0.2, 0.2, 0.2];

    setState(() {
      _installments = percentages.map((p) => {
        "amount": (total * p).toStringAsFixed(0),
        "date": "Select Date",
        "status": "Pending",
        "percent": "${(p * 100).toInt()}%"
      }).toList();
    });
  }

  Future<void> _pickDate(int index) async {
    DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _installments[index]['date'] = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    // Evaluate overall Deal Status dynamically
    int paidCount = _installments.where((i) => i['status'] == 'Paid').length;
    bool isFullyPaid = _installments.isNotEmpty && paidCount == _installments.length;
    String overallStatus = isFullyPaid ? 'Complete' : 'Pending';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: const BackButton(color: Colors.grey),
        title: Text('Deal Configuration', style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<AdminDealProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isSaving || _installments.isEmpty ? null : () async {
                    if (_installments.any((i) => i['date'] == 'Select Date')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select due dates for all installments.')));
                      return;
                    }

                    String jsonString = jsonEncode(_installments);

                    // Save the plan to the backend with the evaluated status (Complete or Pending)
                    bool success = await provider.savePaymentPlan(widget.deal.id.toString(), jsonString, _totalAmountCtrl.text, overallStatus);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plan Saved! Deal Status: $overallStatus')));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: provider.isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isFullyPaid ? 'Save & Complete Deal' : 'Save Payment Plan', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Status Indicator
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isFullyPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: isFullyPaid ? Colors.green : Colors.orange)),
              child: Row(
                children: [
                  Icon(isFullyPaid ? Icons.check_circle : Icons.pending_actions, color: isFullyPaid ? Colors.green : Colors.orange),
                  const SizedBox(width: 12),
                  Text("Overall Deal Status: ${overallStatus.toUpperCase()}", style: TextStyle(fontWeight: FontWeight.bold, color: isFullyPaid ? Colors.green : Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("Payment Configuration", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Configuration Setup
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryBlue.withOpacity(0.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Payable Amount (₹)", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _totalAmountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _generateInstallments(),
                    decoration: InputDecoration(filled: true, fillColor: Colors.grey.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))),
                  ),
                  const SizedBox(height: 16),

                  Text("Installment Plan", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPlan,
                    decoration: InputDecoration(filled: true, fillColor: Colors.grey.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))),
                    items: _plans.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.montserrat(fontSize: 13)))).toList(),
                    onChanged: widget.isReraApproved ? null : (val) {
                      setState(() => _selectedPlan = val!);
                      _generateInstallments();
                    },
                  ),
                  if (widget.isReraApproved)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text("Locked to 100% Upfront due to RERA compliance.", style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Installments Tracker
            if (_installments.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Installment Tracker", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isFullyPaid ? Colors.green.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(isFullyPaid ? "ALL PAID" : "$paidCount / ${_installments.length} PAID", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: isFullyPaid ? Colors.green : primaryBlue)),
                  )
                ],
              ),
              const SizedBox(height: 12),

              ..._installments.asMap().entries.map((entry) {
                int idx = entry.key;
                var inst = entry.value;
                bool isPaid = inst['status'] == 'Paid';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: isPaid ? Colors.green.withOpacity(0.05) : cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isPaid ? Colors.green : Colors.grey.shade300)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isPaid ? Colors.green : primaryBlue, shape: BoxShape.circle),
                        child: Text(inst['percent'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("₹ ${inst['amount']}", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.black87)),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: isPaid ? null : () => _pickDate(idx),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month, size: 14, color: Colors.grey[600]), const SizedBox(width: 4),
                                  Text(inst['date'], style: TextStyle(fontSize: 12, color: inst['date'] == 'Select Date' ? Colors.red : Colors.grey[600], fontWeight: FontWeight.bold, decoration: isPaid ? null : TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(isPaid ? "Paid" : "Pending", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange)),
                          Switch(
                            value: isPaid,
                            activeColor: Colors.green,
                            onChanged: (val) {
                              setState(() {
                                _installments[idx]['status'] = val ? 'Paid' : 'Pending';
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }).toList()
            ]
          ],
        ),
      ),
    );
  }
}