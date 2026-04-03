import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/installment_provider.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:prarambh_infra/features/admin/data/models/installment_model.dart';

class InstallmentDetailsScreen extends StatelessWidget {
  final UpcomingInstallmentModel installment;

  const InstallmentDetailsScreen({super.key, required this.installment});

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isAdmin = context.read<AuthProvider>().currentUser?.role.toLowerCase() == 'admin';

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
          'Installment Details',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPropertyInfoCard(context),
            const SizedBox(height: 16),
            _buildFinancialSummaryCard(context),
            const SizedBox(height: 16),
            _buildAdvisorCommissionCard(context),
            const SizedBox(height: 16),
            _buildAdvisorDetailsCard(context),
            if (isAdmin) ...[
              const SizedBox(height: 16),
              _buildClientDetailsCard(context),
            ],
            const SizedBox(height: 32),
            _buildActionButtons(context, isAdmin),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyInfoCard(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return _buildBaseCard(
      context,
      title: 'Property Info',
      icon: Icons.business,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('PROJECT NAME', installment.projectName ?? 'N/A', isBoldValue: true),
          const SizedBox(height: 12),
          _buildDetailRow('REFERENCE ID', '#INV-${installment.dealId}-${installment.installmentIndex}', isBoldValue: true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: primaryBlue),
                const SizedBox(width: 6),
                Text(
                  installment.unitNumber ?? "Sector 4, Main Road", // Static fallback if missing
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(BuildContext context) {
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);
    final primaryBlue = Theme.of(context).primaryColor;
    
    return _buildBaseCard(
      context,
      title: 'Financial Summary',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTALLMENT AMOUNT - (${installment.installmentIndex + 1}ST INSTALLMENT)',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amountFormatter.format(double.tryParse(installment.installmentAmount) ?? 0),
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailRow('DUE DATE', DateFormat('MMM dd, yyyy').format(DateTime.parse(installment.installmentDate)), isBoldValue: true),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text('STATUS', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                   const SizedBox(height: 4),
                   Row(
                    children: [
                      Icon(
                        installment.installmentStatus == 'Paid' ? Icons.check_circle : Icons.pending_actions,
                        size: 16,
                        color: installment.installmentStatus == 'Paid' ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        installment.installmentStatus,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: installment.installmentStatus == 'Paid' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                   ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorCommissionCard(BuildContext context) {
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);
    final primaryBlue = Theme.of(context).primaryColor;
    
    return _buildBaseCard(
      context,
      title: 'Advisor Commission',
      icon: Icons.percent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryBlue.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PAYOUT AMOUNT', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Text(
              amountFormatter.format((double.tryParse(installment.installmentAmount) ?? 0) * 0.02), // Placeholder calculation
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorDetailsCard(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBaseCard(
      context,
      title: 'Advisor Details',
      icon: Icons.badge_outlined,
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: primaryBlue.withOpacity(0.1),
            child: Text(
              installment.advisorName.isNotEmpty ? installment.advisorName[0].toUpperCase() : 'A',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(installment.advisorName, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('ID: ${installment.advisorCode}', style: GoogleFonts.montserrat(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetailsCard(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;

    return _buildBaseCard(
      context,
      title: 'Client Details',
      icon: Icons.person_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildDetailRow('NAME', installment.clientName, isBoldValue: true),
               IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: primaryBlue),
                onPressed: () {},
               ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTACT', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                  Text(installment.clientNumber, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  _circularIconButton(context, Icons.phone_outlined, Colors.green, () => launchUrl(Uri.parse('tel:${installment.clientNumber}'))),
                  const SizedBox(width: 12),
                  _circularIconButton(context, Icons.chat_bubble_outline, Colors.blue, () => launchUrl(Uri.parse('sms:${installment.clientNumber}'))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circularIconButton(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isAdmin) {
    final provider = context.watch<InstallmentProvider>();
    final primaryBlue = Theme.of(context).primaryColor;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => provider.downloadInvoice(installment),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'DOWNLOAD\nINVOICE',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 13),
            ),
          ),
        ),
        if (isAdmin && installment.installmentStatus != 'Paid') ...[
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final success = await provider.markAsPaid(installment.dealId, installment.installmentIndex);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as paid successfully!')));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: provider.isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    'MARK PAID',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBaseCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
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
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Icon(icon, color: primaryBlue, size: 20),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBoldValue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
