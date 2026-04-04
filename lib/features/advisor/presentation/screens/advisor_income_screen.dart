import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/advisor_income_provider.dart';

class MyIncomeAnalyticsScreen extends StatefulWidget {
  const MyIncomeAnalyticsScreen({super.key});

  @override
  State<MyIncomeAnalyticsScreen> createState() => _MyIncomeAnalyticsScreenState();
}

class _MyIncomeAnalyticsScreenState extends State<MyIncomeAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<AdvisorIncomeProvider>().fetchAdvisorIncome(authProvider.currentUser!.advisorCode!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final incomeProvider = context.watch<AdvisorIncomeProvider>();
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final textColor = AppColors.getTextColor(context);

    return Scaffold(
      backgroundColor: AppColors.getScaffoldColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: textColor),
        title: Text(
          'My Income Analytics',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.filter_list, color: primaryBlue),
          ),
        ],
      ),
      body: incomeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : incomeProvider.errorMessage != null
              ? Center(child: Text('Error: ${incomeProvider.errorMessage}'))
              : RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = context.read<AuthProvider>();
                    final advisorCode = authProvider.currentUser?.advisorCode ?? '';
                    if (advisorCode.isNotEmpty) {
                      await incomeProvider.fetchAdvisorIncome(advisorCode);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Period Selection Tabs
                        _buildPeriodTabs(incomeProvider),
                        const SizedBox(height: 24),

                        // Total Earnings Card
                        _buildSummaryCard(context, incomeProvider),
                        const SizedBox(height: 32),

                        // Earnings by Project
                        _buildSectionHeader(context, "Earnings by Project"),
                        const SizedBox(height: 16),
                        _buildProjectTable(context, incomeProvider),
                        const SizedBox(height: 32),

                        // Earnings by Property
                        _buildSectionHeader(context, "Earnings by Property"),
                        const SizedBox(height: 16),
                        _buildPropertyTable(context, incomeProvider),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPeriodTabs(AdvisorIncomeProvider provider) {
    final periods = ['Weekly', 'Monthly', 'Quarterly', 'Yearly'];
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getBorderColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = provider.selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setPeriod(period),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.getCardColor(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.getPrimaryBlue(context) : AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AdvisorIncomeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final totalEarned = provider.incomeData?.summary.totalEarned ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [primaryBlue.withOpacity(0.3), primaryBlue.withOpacity(0.1)]
              : [primaryBlue.withOpacity(0.15), primaryBlue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            "TOTAL EARNINGS (CURRENT PERIOD)",
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getSecondaryTextColor(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "₹ ${totalEarned.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: GoogleFonts.montserrat(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  "+12% vs last month",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "VIEW ALL",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryBlue(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectTable(BuildContext context, AdvisorIncomeProvider provider) {
    final summaries = provider.earningsByProject;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.getBorderColor(context).withOpacity(0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerCell("PROJECT NAME")),
                Expanded(flex: 1, child: _headerCell("UNITS", textAlign: TextAlign.center)),
                Expanded(flex: 2, child: _headerCell("COMMISSION", textAlign: TextAlign.right)),
              ],
            ),
          ),
          // Table Body
          if (summaries.isEmpty)
             const Padding(padding: EdgeInsets.all(20), child: Text("No project data available"))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summaries.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.getBorderColor(context)),
              itemBuilder: (context, index) {
                final item = summaries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.projectName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(item.units.toString(), textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("₹ ${item.totalCommission.toStringAsFixed(0)}", textAlign: TextAlign.right, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyTable(BuildContext context, AdvisorIncomeProvider provider) {
    final txs = provider.incomeData?.transactions ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.getBorderColor(context).withOpacity(0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerCell("PROPERTY NAME")),
                Expanded(flex: 2, child: _headerCell("PROJECT")),
                Expanded(flex: 2, child: _headerCell("COMMISSION", textAlign: TextAlign.right)),
              ],
            ),
          ),
          // Table Body
          if (txs.isEmpty)
             const Padding(padding: EdgeInsets.all(20), child: Text("No property data available"))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: txs.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.getBorderColor(context)),
              itemBuilder: (context, index) {
                final tx = txs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                             Container(
                               width: 32, height: 32,
                               alignment: Alignment.center,
                               decoration: BoxDecoration(color: AppColors.getPrimaryBlue(context).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                               child: Text(tx.unitNumber.split('-').first, style: TextStyle(color: AppColors.getPrimaryBlue(context), fontWeight: FontWeight.bold, fontSize: 11)),
                             ),
                             const SizedBox(width: 10),
                             Text(tx.unitNumber, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(tx.projectName, style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.getSecondaryTextColor(context))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("₹ ${tx.totalCommission.toStringAsFixed(0)}", textAlign: TextAlign.right, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.left}) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.getSecondaryTextColor(context),
      ),
    );
  }
}
