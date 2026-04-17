import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProject;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstallmentProvider>().fetchUpcomingInstallments();
      // Also fetch projects for the dropdown
      final projectProvider = context.read<AdminProjectProvider>();
      if (projectProvider.projects.isEmpty) {
        projectProvider.fetchProjects();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UpcomingInstallmentModel> _getFilteredInstallments(List<UpcomingInstallmentModel> installments) {
    return installments.where((item) {
      final search = _searchController.text.toLowerCase();
      final matchesSearch = search.isEmpty ||
          item.advisorName.toLowerCase().contains(search) ||
          item.clientName.toLowerCase().contains(search) ||
          item.advisorCode.toLowerCase().contains(search) ||
          (item.unitNumber != null && item.unitNumber!.toLowerCase().contains(search));

      final matchesProject = _selectedProject == null || _selectedProject == 'All Projects' || item.projectName == _selectedProject;

      bool matchesDate = true;
      if (_startDate != null || _endDate != null) {
        try {
          final date = DateTime.parse(item.installmentDate);
          if (_startDate != null && date.isBefore(_startDate!)) matchesDate = false;
          if (_endDate != null && date.isAfter(_endDate!.add(const Duration(days: 1)))) matchesDate = false;
        } catch (_) {
          matchesDate = false;
        }
      }

      return matchesSearch && matchesProject && matchesDate;
    }).toList();
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
        toolbarHeight: 50, // Shrunk AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upcoming Installment',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16, // Slightly smaller font
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFilterVisible ? Icons.filter_list_off : Icons.filter_list, color: Colors.white, size: 20),
            onPressed: () => setState(() => _isFilterVisible = !_isFilterVisible),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAdminHeader(context, provider),
          if (_isFilterVisible) _buildFilterSection(context),
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : provider.error != null
                    ? Center(child: Text(provider.error!, style: GoogleFonts.montserrat(color: Colors.red)))
                    : _getFilteredInstallments(provider.upcomingInstallments).isEmpty
                        ? _buildEmptyState(context)
                        : _buildInstallmentList(context, _getFilteredInstallments(provider.upcomingInstallments)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context, InstallmentProvider provider) {
    final primaryBlue = Theme.of(context).primaryColor;
    final amountFormatter = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);
    final filtered = _getFilteredInstallments(provider.upcomingInstallments);

    double totalAmount = filtered.fold(0, (sum, item) => sum + (double.tryParse(item.installmentAmount) ?? 0));
    String count = filtered.length.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: primaryBlue,
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {}),
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.white,
              style: GoogleFonts.montserrat(color: Colors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search advisor, client, code, unit...',
                hintStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: Colors.black, size: 18),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryBox(context, 'FILTERED DUE', amountFormatter.format(totalAmount)),
              const SizedBox(width: 12),
              _summaryBox(context, 'COUNT', count),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final projectProvider = context.watch<AdminProjectProvider>();
    final projects = ['All Projects', ...projectProvider.projects.map((e) => e.projectName)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Project Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROJECT', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedProject ?? 'All Projects',
                          isExpanded: true,
                          items: projects.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.montserrat(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedProject = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Reset Button
              IconButton(
                onPressed: () => setState(() {
                  _selectedProject = null;
                  _startDate = null;
                  _endDate = null;
                }),
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Reset Filters',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date Range
          Row(
            children: [
              Expanded(
                child: _datePickerFilter(
                  label: 'START DATE',
                  date: _startDate,
                  onSelect: (d) => setState(() => _startDate = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _datePickerFilter(
                  label: 'END DATE',
                  date: _endDate,
                  onSelect: (d) => setState(() => _endDate = d),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePickerFilter({required String label, DateTime? date, required Function(DateTime) onSelect}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) onSelect(picked);
          },
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  date == null ? 'Select' : DateFormat('dd/MM/yy').format(date),
                  style: GoogleFonts.montserrat(fontSize: 11),
                ),
                if (date != null) ...[
                  const Spacer(),
                  InkWell(
                    onTap: () => setState(() {
                      if (label == 'START DATE') {
                        _startDate = null;
                      } else {
                        _endDate = null;
                      }
                    }),
                    child: const Icon(Icons.close, size: 12, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
