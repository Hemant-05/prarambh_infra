import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_analytics_provider.dart';
import '../../data/models/sales_analytics_model.dart';

class AdminSalesAnalyticsScreen extends StatefulWidget {
  const AdminSalesAnalyticsScreen({super.key});

  @override
  State<AdminSalesAnalyticsScreen> createState() => _AdminSalesAnalyticsScreenState();
}

class _AdminSalesAnalyticsScreenState extends State<AdminSalesAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchSalesAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminAnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.getScaffoldColor(context),
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchSalesAnalytics(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? _buildErrorView(provider.errorMessage!)
              : provider.analyticsData == null
                  ? const Center(child: Text("No analytics data available"))
                  : _buildMainContent(context, provider.analyticsData!),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<AdminAnalyticsProvider>().fetchSalesAnalytics(),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, SalesAnalyticsModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(data.summary),
          const SizedBox(height: 30),
          _buildSectionHeader("Revenue Trend (Monthly)"),
          const SizedBox(height: 16),
          _buildMonthlyBarChart(data.barChartMonthly),
          const SizedBox(height: 30),
          _buildSectionHeader("Deals by Project"),
          const SizedBox(height: 16),
          _buildProjectPieChart(data.pieChartProjects),
          const SizedBox(height: 30),
          _buildSectionHeader("Sales Funnel"),
          const SizedBox(height: 16),
          _buildLeadFunnel(data.funnelChartLeads),
          const SizedBox(height: 30),
          _buildSectionHeader("Top Performing Advisors"),
          const SizedBox(height: 16),
          _buildTopAdvisorsList(data.topAdvisors),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextColor(context),
      ),
    );
  }

  Widget _buildSummaryCards(SalesSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            "Total Revenue",
            "₹${_formatCurrency(summary.totalRevenue)}",
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            "Total Deals",
            summary.totalDeals.toString(),
            Icons.handshake,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppColors.getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart(List<MonthlyChartData> data) {
    if (data.isEmpty) return const Center(child: Text("No monthly data"));

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          groupsSpace: 40,
          maxY: (data.map((e) => e.totalRevenue).reduce((a, b) => a > b ? a : b) * 1.3).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${data[groupIndex].month}\n₹${_formatCurrency(rod.toY)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[index].month.split(' ')[0],
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatCurrencyShort(value),
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.getSecondaryTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (data.map((e) => e.totalRevenue).reduce((a, b) => a > b ? a : b) / 3).toDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.getBorderColor(context),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalRevenue,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getPrimaryBlue(context),
                      AppColors.getPrimaryBlue(context).withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 35,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: (data.map((e) => e.totalRevenue).reduce((a, b) => a > b ? a : b) * 1.3).toDouble(),
                    color: AppColors.getBorderColor(context).withOpacity(0.1),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProjectPieChart(List<ProjectChartData> data) {
    if (data.isEmpty) return const Center(child: Text("No project data"));

    List<Color> colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.teal];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0, // Making it a solid pie chart
                sections: data.asMap().entries.map((entry) {
                  return PieChartSectionData(
                    color: colors[entry.key % colors.length],
                    value: entry.value.dealsCount.toDouble(),
                    title: '${entry.value.dealsCount}',
                    radius: 80,
                    titleStyle: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[entry.key % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value.projectName,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadFunnel(List<FunnelStageData> data) {
    if (data.isEmpty) return const Center(child: Text("No funnel data"));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Column(
        children: data.map((item) {
          double widthFactor = (item.count / data.map((e) => e.count).reduce((a, b) => a > b ? a : b));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.displayLabel,
                      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item.count.toString(),
                      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: widthFactor.clamp(0.05, 1.0),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.blue.withOpacity(0.6)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopAdvisorsList(List<AdvisorPerformanceData> advisors) {
    if (advisors.isEmpty) return const Center(child: Text("No advisor data"));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: advisors.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.getBorderColor(context)),
        itemBuilder: (context, index) {
          final advisor = advisors[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.withOpacity(0.1),
              backgroundImage: advisor.profilePhoto != null && advisor.profilePhoto!.isNotEmpty
                  ? (advisor.profilePhoto!.startsWith('http') 
                      ? NetworkImage(advisor.profilePhoto!) 
                      : NetworkImage("https://workiees.com/${advisor.profilePhoto}"))
                  : null,
              child: advisor.profilePhoto == null || advisor.profilePhoto!.isEmpty
                  ? Text(advisor.fullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                  : null,
            ),
            title: Text(
              advisor.fullName,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              "Code: ${advisor.advisorCode}",
              style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.getSecondaryTextColor(context)),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${_formatCurrency(advisor.totalRevenue)}",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                ),
                Text(
                  "${advisor.totalDeals} Deals",
                  style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(2)} Cr";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)} L";
    } else {
      return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }
  }

  String _formatCurrencyShort(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(1)}C";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(1)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
