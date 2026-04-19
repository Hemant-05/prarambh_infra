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
  int _selectedTab = 0; // 0: Paid, 1: Pending
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getScaffoldColor(context),
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).cardColor : AppColors.primaryBlueLight,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'My Income',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                        // _buildPeriodTabs(incomeProvider),
                        // const SizedBox(height: 24),

                        // Total Earnings Card
                        _buildSummaryCard(context, incomeProvider),
                        const SizedBox(height: 32),

                        // Earnings by Project
                        _buildSectionHeader(context, "Earning by Project", showViewAll: false),
                        const SizedBox(height: 16),
                        _buildProjectTable(context, incomeProvider),
                        const SizedBox(height: 32),

                        // Earnings by Property (Filtered Transactions)
                        _buildSectionHeader(context, "Recent Transactions", showViewAll: false),
                        const SizedBox(height: 16),
                        _buildTransactionTabs(),
                        const SizedBox(height: 16),
                        _buildTransactionTable(context, incomeProvider),
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

  Widget _buildSummaryCard(
      BuildContext context, AdvisorIncomeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final totalGross = provider.incomeData?.summary.totalGross ?? 0;
    final totalEarned = provider.incomeData?.summary.totalEarned ?? 0;
    final totalPending = provider.incomeData?.summary.totalPending ?? 0;

    String formatCurrency(double amount) {
      return "₹ ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem(
            context,
            "TOTAL GROSS",
            formatCurrency(totalGross),
            primaryBlue,
            Icons.account_balance_wallet_outlined,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMiniCard(
                  context,
                  "Earned",
                  "₹${totalEarned.toStringAsFixed(0)}",
                  Colors.green,
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryMiniCard(
                  context,
                  "Pending",
                  "₹${totalPending.toStringAsFixed(0)}",
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value,
      Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.getTextColor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryMiniCard(BuildContext context, String title, String amount, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {bool showViewAll = true}) {
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
        if (showViewAll)
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

  Widget _buildTransactionTabs() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getBorderColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabItem(0, "Paid"),
          _buildTabItem(1, "Pending"),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
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
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.getPrimaryBlue(context) : AppColors.getSecondaryTextColor(context),
            ),
          ),
        ),
      ),
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

  Widget _buildTransactionTable(
      BuildContext context, AdvisorIncomeProvider provider) {
    final allTxs = provider.incomeData?.transactions ?? [];

    // Filter transactions based on selected tab
    final txs = _selectedTab == 0
        ? allTxs.where((tx) => tx.status.toLowerCase() == 'paid').toList()
        : allTxs
            .where((tx) => tx.status.toLowerCase().contains('pending'))
            .toList();

    if (txs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorderColor(context)),
        ),
        child: Center(
          child: Text(
            _selectedTab == 0
                ? "No paid transactions yet"
                : "No pending transactions",
            style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: AppColors.getBorderColor(context),
          ),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              AppColors.getBorderColor(context).withOpacity(0.3),
            ),
            columnSpacing: 24,
            horizontalMargin: 16,
            dataRowHeight: 55,
            columns: [
              _tableHeader("DATE"),
              _tableHeader("PROJECT"),
              _tableHeader("UNIT"),
              _tableHeader("CLIENT"),
              _tableHeader("GROSS", isNumeric: true),
              _tableHeader("SLAB", isNumeric: true),
              _tableHeader("INST. COMM", isNumeric: true),
              _tableHeader("NET", isNumeric: true),
              _tableHeader("STATUS"),
            ],
            rows: txs.map((tx) {
              final isPaid = tx.status.toLowerCase() == 'paid';
              final isUnverified =
                  tx.status.toLowerCase().contains('not verified');
              final statusColor = isPaid
                  ? Colors.green
                  : (isUnverified ? Colors.red : Colors.orange);

              return DataRow(
                cells: [
                  DataCell(_tableCell(tx.formattedDate)),
                  DataCell(_tableCell(tx.projectName, isBold: true)),
                  DataCell(_tableCell(tx.unitNumber)),
                  DataCell(_tableCell(tx.clientName ?? 'N/A')),
                  DataCell(_tableCell("₹${tx.gross.toStringAsFixed(0)}",
                      isNumeric: true)),
                  DataCell(_tableCell("${tx.slab.toStringAsFixed(0)}",
                      isNumeric: true)),
                  DataCell(_tableCell(
                      "₹${tx.installmentCommission.toStringAsFixed(0)}",
                      isNumeric: true,
                      color: isPaid ? Colors.green : null)),
                  DataCell(_tableCell("₹${tx.net.toStringAsFixed(0)}",
                      isNumeric: true, isBold: true)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.status.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _tableHeader(String label, {bool isNumeric = false}) {
    return DataColumn(
      numeric: isNumeric,
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.getSecondaryTextColor(context),
        ),
      ),
    );
  }

  Widget _tableCell(String text,
      {bool isNumeric = false,
      bool isBold = false,
      Color? color,
      TextAlign? textAlign}) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        color: color ?? AppColors.getTextColor(context),
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
