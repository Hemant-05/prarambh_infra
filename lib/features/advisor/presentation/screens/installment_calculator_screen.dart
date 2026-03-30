// lib/features/advisor/presentation/screens/installment_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InstallmentCalculatorScreen extends StatefulWidget {
  const InstallmentCalculatorScreen({super.key});

  @override
  State<InstallmentCalculatorScreen> createState() => _InstallmentCalculatorScreenState();
}

class _InstallmentCalculatorScreenState extends State<InstallmentCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final Color _primaryBlue = const Color(0xFF0056A4);
  
  Map<String, dynamic>? _selectedPlan;
  List<double> _installments = [];

  final List<Map<String, dynamic>> _plans = [
    {'name': '25% - 75%', 'percentages': [25, 75]},
    {'name': '50% - 50%', 'percentages': [50, 50]},
    {'name': '33% - 33% - 34%', 'percentages': [33, 33, 34]},
    {'name': '25% - 25% - 50%', 'percentages': [25, 25, 50]},
    {'name': '25% - 25% - 25% - 25%', 'percentages': [25, 25, 25, 25]},
    {'name': '20% - 20% - 20% - 20% - 20%', 'percentages': [20, 20, 20, 20, 20]},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = _plans[0];
  }

  void _calculateInstallments() {
    if (_amountController.text.isEmpty) {
      setState(() => _installments = []);
      return;
    }

    double totalAmount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (totalAmount <= 0) {
      setState(() => _installments = []);
      return;
    }

    if (_selectedPlan != null) {
      List<int> percentages = _selectedPlan!['percentages'];
      List<double> calculated = percentages.map((p) => (totalAmount * p) / 100).toList();
      setState(() => _installments = calculated);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        title: Text(
          'Installment Calculator',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInputHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Installment Plan'),
                  const SizedBox(height: 12),
                  _buildPlanSelector(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Payment Breakdown'),
                  const SizedBox(height: 12),
                  _installments.isEmpty
                      ? _buildEmptyState()
                      : _buildResultList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Property Amount',
            style: GoogleFonts.montserrat(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            cursorColor: Colors.white,
            onChanged: (_) => _calculateInstallments(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.currency_rupee, color: Colors.white, size: 28),
              hintText: 'Enter Amount',
              hintStyle: GoogleFonts.montserrat(
                color: Colors.white.withOpacity(0.5),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _plans.map((plan) {
        bool isSelected = _selectedPlan == plan;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedPlan = plan);
            _calculateInstallments();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? _primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _primaryBlue : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              plan['name'],
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _installments.length,
      itemBuilder: (context, index) {
        final percentage = _selectedPlan!['percentages'][index];
        final amount = _installments[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.montserrat(
                      color: _primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installment ${index + 1}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Payment share: $percentage%',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(amount),
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Enter total amount to see breakdown',
            style: GoogleFonts.montserrat(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
