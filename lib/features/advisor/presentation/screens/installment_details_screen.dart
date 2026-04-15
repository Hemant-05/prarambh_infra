import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/installment_provider.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:prarambh_infra/features/admin/data/models/installment_model.dart';
import 'package:prarambh_infra/features/admin/data/models/unit_model.dart';
import 'package:prarambh_infra/features/admin/data/models/deal_model.dart';

class InstallmentDetailsScreen extends StatefulWidget {
  final UpcomingInstallmentModel installment;

  const InstallmentDetailsScreen({super.key, required this.installment});

  @override
  State<InstallmentDetailsScreen> createState() => _InstallmentDetailsScreenState();
}

class _InstallmentDetailsScreenState extends State<InstallmentDetailsScreen> {
  UnitModel? _unit;
  bool _isLoadingUnit = false;

  @override
  void initState() {
    super.initState();
    _fetchDetailedInfo();
  }

  Future<void> _fetchDetailedInfo() async {
    setState(() => _isLoadingUnit = true);
    try {
      final installmentRepo = context.read<InstallmentProvider>().repository;
      final projectProvider = context.read<AdminProjectProvider>();

      // 1. Fetch Deal to get Unit ID
      final dealResponse = await installmentRepo.apiClient.getSingleDeal(widget.installment.dealId.toString());
      if (dealResponse['status'] == true) {
        final deal = DealModel.fromJson(dealResponse['data']);
        
        // 2. Fetch Unit Details
        final unit = await projectProvider.getUnitDetails(deal.unitId.toString());
        if (mounted) {
          setState(() {
            _unit = unit;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching unit details: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingUnit = false);
      }
    }
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBaseCard(
      context,
      title: 'Property details',
      icon: Icons.business,
      child: _isLoadingUnit 
        ? Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(color: primaryBlue, strokeWidth: 2),
          ))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(child: _buildDetailRow('PROJECT NAME', widget.installment.projectName ?? 'N/A', isBoldValue: true)),
                   if (_unit != null) ...[
                     const SizedBox(width: 12),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _unit!.saleCategory.toUpperCase(),
                          style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue),
                        ),
                      ),
                   ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('UNIT / PLOT NO', _unit?.unitNumber ?? widget.installment.unitNumber ?? 'N/A', isBoldValue: true)),
                  Expanded(child: _buildDetailRow('PROPERTY TYPE', _unit?.propertyType ?? 'N/A', isBoldValue: true)),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('AREA (SQFT)', _unit?.areaSqft.toString() ?? 'N/A', isBoldValue: true)),
                  Expanded(child: _buildDetailRow('RATE / SQFT', _unit != null ? '₹${_unit!.ratePerSqft}' : 'N/A', isBoldValue: true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('FACING', _unit?.facing ?? 'N/A', isBoldValue: true)),
                  Expanded(child: _buildDetailRow('DIMENSIONS', _unit?.plotDimensions ?? 'N/A', isBoldValue: true)),
                ],
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
            'INSTALLMENT AMOUNT - (${widget.installment.installmentIndex + 1}ST INSTALLMENT)',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amountFormatter.format(double.tryParse(widget.installment.installmentAmount) ?? 0),
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
              _buildDetailRow('DUE DATE', DateFormat('MMM dd, yyyy').format(DateTime.parse(widget.installment.installmentDate)), isBoldValue: true),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text('STATUS', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                   const SizedBox(height: 4),
                   Row(
                    children: [
                      Icon(
                        widget.installment.installmentStatus == 'Paid' ? Icons.check_circle : Icons.pending_actions,
                        size: 16,
                        color: widget.installment.installmentStatus == 'Paid' ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.installment.installmentStatus,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.installment.installmentStatus == 'Paid' ? Colors.green : Colors.orange,
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
              amountFormatter.format((double.tryParse(widget.installment.installmentAmount) ?? 0) * 0.02), // Placeholder calculation
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
              widget.installment.advisorName.isNotEmpty ? widget.installment.advisorName[0].toUpperCase() : 'A',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.installment.advisorName, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('ID: ${widget.installment.advisorCode}', style: GoogleFonts.montserrat(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600)),
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
               _buildDetailRow('NAME', widget.installment.clientName, isBoldValue: true)
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
                  Text(widget.installment.clientNumber, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  _circularIconButton(context, Icons.phone_outlined, Colors.green, () => launchUrl(Uri.parse('tel:${widget.installment.clientNumber}'))),
                  const SizedBox(width: 12),
                  _circularIconButton(context, Icons.chat_bubble_outline, Colors.blue, () => launchUrl(Uri.parse('sms:${widget.installment.clientNumber}'))),
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
            onPressed: () => provider.downloadInvoice(widget.installment),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'DOWNLOAD\nRECEIPT',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 13),
            ),
          ),
        ),
        if (isAdmin && widget.installment.installmentStatus != 'Paid') ...[
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final success = await provider.markAsPaid(widget.installment.dealId, widget.installment.installmentIndex);
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
