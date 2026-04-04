// lib/features/advisor/presentation/screens/installment_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class InstallmentCalculatorScreen extends StatefulWidget {
  const InstallmentCalculatorScreen({super.key});

  @override
  State<InstallmentCalculatorScreen> createState() => _InstallmentCalculatorScreenState();
}

class _InstallmentCalculatorScreenState extends State<InstallmentCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  
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
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final scaffoldBg = AppColors.getScaffoldColor(context);
    final cardColor = AppColors.getCardColor(context);
    final textColor = AppColors.getTextColor(context);
    final secondaryTextColor = AppColors.getSecondaryTextColor(context);
    final borderColor = AppColors.getBorderColor(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: primaryBlue,
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
            _buildInputHeader(primaryBlue),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Installment Plan', textColor),
                  const SizedBox(height: 12),
                  _buildPlanSelector(
                    primaryBlue,
                    cardColor,
                    borderColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Payment Breakdown', textColor),
                  const SizedBox(height: 12),
                  _installments.isEmpty
                      ? _buildEmptyState(
                          cardColor,
                          borderColor,
                          secondaryTextColor,
                        )
                      : _buildResultList(
                          primaryBlue,
                          cardColor,
                          borderColor,
                          textColor,
                          secondaryTextColor,
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputHeader(Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: primaryBlue,
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  Widget _buildPlanSelector(Color primaryBlue, Color cardColor, Color borderColor, Color secondaryTextColor) {
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
              color: isSelected ? primaryBlue : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryBlue : borderColor,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
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
                color: isSelected ? Colors.white : secondaryTextColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultList(Color primaryBlue, Color cardColor, Color borderColor, Color textColor, Color secondaryTextColor) {
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
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02),
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
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.montserrat(
                      color: primaryBlue,
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
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Payment share: $percentage%',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: secondaryTextColor,
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
                  color: const Color(0xFF4CAF50), // Standard material green for price
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color cardColor, Color borderColor, Color secondaryTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined, size: 60, color: secondaryTextColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Enter total amount to see breakdown',
            style: GoogleFonts.montserrat(
              color: secondaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}
