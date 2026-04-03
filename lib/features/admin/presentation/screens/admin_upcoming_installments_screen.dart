import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/installment_provider.dart';
import 'package:prarambh_infra/features/admin/data/models/installment_model.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/installment_details_screen.dart';

class AdminUpcomingInstallmentsScreen extends StatefulWidget {
  const AdminUpcomingInstallmentsScreen({super.key});

  @override
  State<AdminUpcomingInstallmentsScreen> createState() => _AdminUpcomingInstallmentsScreenState();
}

class _AdminUpcomingInstallmentsScreenState extends State<AdminUpcomingInstallmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetching without advisorCode for Admin to see all
      context.read<InstallmentProvider>().fetchUpcomingInstallments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstallmentProvider>();
    final primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Company Installments',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildAdminHeader(context, provider),
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : provider.error != null
                    ? Center(child: Text(provider.error!, style: GoogleFonts.montserrat(color: Colors.red)))
                    : provider.upcomingInstallments.isEmpty
                        ? _buildEmptyState(context)
                        : _buildInstallmentList(context, provider.upcomingInstallments),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context, InstallmentProvider provider) {
    final primaryBlue = Theme.of(context).primaryColor;
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    double totalAmount = provider.upcomingInstallments.fold(0, (sum, item) => sum + (double.tryParse(item.installmentAmount) ?? 0));
    String count = provider.upcomingInstallments.length.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: primaryBlue,
      child: Row(
        children: [
          _summaryBox(context, 'OVERALL DUE', amountFormatter.format(totalAmount)),
          const SizedBox(width: 12),
          _summaryBox(context, 'TOTAL PENDING', count),
        ],
      ),
    );
  }

  Widget _summaryBox(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentList(BuildContext context, List<UpcomingInstallmentModel> installments) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: installments.length,
      itemBuilder: (context, index) {
        final item = installments[index];
        // Reuse the logic from the Advisor card but maybe add Advisor Name for Admin
        return _buildAdminInstallmentCard(context, item);
      },
    );
  }

  Widget _buildAdminInstallmentCard(BuildContext context, UpcomingInstallmentModel installment) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);
    
    final dueDate = DateTime.parse(installment.installmentDate);
    final isOverdue = installment.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOverdue ? 'OVERDUE' : 'UPCOMING',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : Colors.green,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(dueDate),
                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            installment.clientName,
            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Advisor: ${installment.advisorName}',
            style: GoogleFonts.montserrat(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amountFormatter.format(double.tryParse(installment.installmentAmount) ?? 0),
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstallmentDetailsScreen(installment: installment),
                    ),
                  );
                },
                child: Text('Manage', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: primaryBlue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(child: Text('No upcoming installments for the whole company.', style: GoogleFonts.montserrat(color: Colors.grey)));
  }
}
