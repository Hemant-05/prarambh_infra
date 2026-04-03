import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/installment_provider.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:prarambh_infra/features/admin/data/models/installment_model.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/installment_details_screen.dart';

class UpcomingInstallmentsScreen extends StatefulWidget {
  const UpcomingInstallmentsScreen({super.key});

  @override
  State<UpcomingInstallmentsScreen> createState() => _UpcomingInstallmentsScreenState();
}

class _UpcomingInstallmentsScreenState extends State<UpcomingInstallmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode;
      context.read<InstallmentProvider>().fetchUpcomingInstallments(advisorCode: advisorCode);
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
        title: Row(
          children: [
            const Icon(Icons.business, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'PRARAMBH INFRA',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context, provider),
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

  Widget _buildHeader(BuildContext context, InstallmentProvider provider) {
    final primaryBlue = Theme.of(context).primaryColor;
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    double totalAmount = 0;
    String nextDue = "N/A";

    if (provider.upcomingInstallments.isNotEmpty) {
      totalAmount = provider.upcomingInstallments.fold(0, (sum, item) => sum + (double.tryParse(item.installmentAmount) ?? 0));
      nextDue = DateFormat('MMM dd').format(DateTime.parse(provider.upcomingInstallments.first.installmentDate));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
            'Upcoming Installments',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryChip(context, Icons.calendar_today, 'Next due: $nextDue'),
              const SizedBox(width: 12),
              _buildSummaryChip(context, Icons.account_balance_wallet, 'Total: ${amountFormatter.format(totalAmount)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentList(BuildContext context, List<UpcomingInstallmentModel> installments) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: installments.length,
      itemBuilder: (context, index) {
        return _buildInstallmentCard(context, installments[index]);
      },
    );
  }

  Widget _buildInstallmentCard(BuildContext context, UpcomingInstallmentModel installment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);
    
    final dueDate = DateTime.parse(installment.installmentDate);
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;
    final isOverdue = installment.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.info_outline,
                    color: isOverdue ? Colors.orange : primaryBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOverdue ? 'Overdue' : 'Due in $daysRemaining days',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? Colors.orange : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(dueDate),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            installment.projectName ?? 'Unit: ${installment.unitNumber ?? "N/A"}',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ref: #INV-${installment.dealId}-${installment.installmentIndex}',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INSTALLMENT AMOUNT',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amountFormatter.format(double.tryParse(installment.installmentAmount) ?? 0),
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstallmentDetailsScreen(installment: installment),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.montserrat(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No upcoming installments',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are all caught up!',
            style: GoogleFonts.montserrat(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
