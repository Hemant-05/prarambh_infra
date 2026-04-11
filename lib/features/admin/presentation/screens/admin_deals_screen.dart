import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/deal_model.dart';
import '../providers/admin_deal_provider.dart';
import '../providers/admin_project_provider.dart';
import 'deal_management_screen.dart';

class AdminDealsScreen extends StatefulWidget {
  final String? initialVerificationStatus;
  const AdminDealsScreen({super.key, this.initialVerificationStatus});

  @override
  State<AdminDealsScreen> createState() => _AdminDealsScreenState();
}

class _AdminDealsScreenState extends State<AdminDealsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = "";

  // Filter States
  String? _selectedPaymentStatus;
  String? _selectedVerificationStatus;
  int? _selectedProjectId;
  DateTimeRange? _selectedDateRange;
  int? _selectedInstallmentCount;

  @override
  void initState() {
    super.initState();
    _selectedVerificationStatus = widget.initialVerificationStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDealProvider>().fetchAllDeals();
      context.read<AdminProjectProvider>().fetchProjects();
    });
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DealModel> _getFilteredDeals(List<DealModel> allDeals) {
    return allDeals.where((deal) {
      // 1. Search filter (Client Name or Advisor Code)
      final matchesSearch =
          deal.clientName.toLowerCase().contains(_searchQuery) ||
          deal.advisorCode.toLowerCase().contains(_searchQuery) ||
          deal.id.toString().contains(_searchQuery);
      if (!matchesSearch) return false;

      // 2. Payment Status Filter
      if (_selectedPaymentStatus != null) {
        if (deal.paymentStatus.toLowerCase() !=
            _selectedPaymentStatus!.toLowerCase())
          return false;
      }

      // 3. Verification Status Filter
      if (_selectedVerificationStatus != null) {
        if (deal.dealStatus.toLowerCase() !=
            _selectedVerificationStatus!.toLowerCase())
          return false;
      }

      // 4. Project Filter
      if (_selectedProjectId != null) {
        if (deal.propertyId != _selectedProjectId) return false;
      }

      // 5. Date Range Filter
      if (_selectedDateRange != null) {
        try {
          final dealDate = DateTime.parse(deal.createdAt.split(' ')[0]);
          if (dealDate.isBefore(_selectedDateRange!.start) ||
              dealDate.isAfter(_selectedDateRange!.end)) {
            return false;
          }
        } catch (_) {}
      }

      // 6. Installments Count Filter
      if (_selectedInstallmentCount != null) {
        if (deal.installments.length != _selectedInstallmentCount) return false;
      }

      return true;
    }).toList();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedPaymentStatus != null) count++;
    if (_selectedVerificationStatus != null) count++;
    if (_selectedProjectId != null) count++;
    if (_selectedDateRange != null) count++;
    if (_selectedInstallmentCount != null) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _selectedPaymentStatus = null;
      _selectedVerificationStatus = null;
      _selectedProjectId = null;
      _selectedDateRange = null;
      _selectedInstallmentCount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search deals...',
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => _searchCtrl.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryBlue.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.filter_list, color: primaryBlue),
                          onPressed: () =>
                              _showFilterSheet(context, isDark, primaryBlue),
                        ),
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Consumer<AdminDealProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    );
                  }

                  final filteredDeals = _getFilteredDeals(provider.deals);

                  if (filteredDeals.isEmpty) {
                    return _buildEmptyState(
                      primaryBlue,
                      isFiltered:
                          _searchQuery.isNotEmpty || _activeFilterCount > 0,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchAllDeals();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDeals.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final deal = filteredDeals[index];
                        return _buildDealCard(
                          context,
                          deal,
                          primaryBlue,
                          isDark,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, bool isDark, Color primaryBlue) {
    final projectProvider = context.read<AdminProjectProvider>();
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearFilters();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Reset All',
                            style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Payment Status
                    _buildFilterSection(
                      'Payment Status',
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentStatus,
                        dropdownColor: sheetBg,
                        style: GoogleFonts.montserrat(
                          color: textColor,
                          fontSize: 13,
                        ),
                        items: ['Pending', 'Paid', 'Partially Paid']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() => _selectedPaymentStatus = val);
                          setState(() => _selectedPaymentStatus = val);
                        },
                        decoration: _inputDecoration(isDark),
                      ),
                    ),

                    // Verification Status
                    _buildFilterSection(
                      'Verification Status',
                      DropdownButtonFormField<String>(
                        value: _selectedVerificationStatus,
                        dropdownColor: sheetBg,
                        style: GoogleFonts.montserrat(
                          color: textColor,
                          fontSize: 13,
                        ),
                        items: ['Verified', 'Not Verified']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(
                            () => _selectedVerificationStatus = val,
                          );
                          setState(() => _selectedVerificationStatus = val);
                        },
                        decoration: _inputDecoration(isDark),
                      ),
                    ),

                    // Project
                    _buildFilterSection(
                      'Project',
                      DropdownButtonFormField<int>(
                        value: _selectedProjectId,
                        dropdownColor: sheetBg,
                        isExpanded: true,
                        style: GoogleFonts.montserrat(
                          color: textColor,
                          fontSize: 13,
                        ),
                        items: projectProvider.projects
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(
                                  p.projectName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() => _selectedProjectId = val);
                          setState(() => _selectedProjectId = val);
                        },
                        decoration: _inputDecoration(isDark),
                      ),
                    ),

                    // Date Range
                    _buildFilterSection(
                      'Date Range',
                      InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: _selectedDateRange,
                          );
                          if (range != null) {
                            setModalState(() => _selectedDateRange = range);
                            setState(() => _selectedDateRange = range);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDateRange == null
                                    ? 'Select Date Range'
                                    : '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Installments
                    _buildFilterSection(
                      'Number of Installments',
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: (_selectedInstallmentCount ?? 0)
                                  .toDouble(),
                              min: 0,
                              max: 12,
                              divisions: 12,
                              label:
                                  _selectedInstallmentCount?.toString() ??
                                  'Any',
                              onChanged: (val) {
                                setModalState(
                                  () => _selectedInstallmentCount = val == 0
                                      ? null
                                      : val.toInt(),
                                );
                                setState(
                                  () => _selectedInstallmentCount = val == 0
                                      ? null
                                      : val.toInt(),
                                );
                              },
                            ),
                          ),
                          Text(
                            _selectedInstallmentCount?.toString() ?? 'Any',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildEmptyState(Color primaryBlue, {bool isFiltered = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off_outlined : Icons.handshake_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? "No Matching Deals" : "No Deals Found",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? "Try adjusting your search or filters."
                : "Deals initiated by advisors will appear here.",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          if (isFiltered)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh),
              label: const Text("Clear All Filters"),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                context.read<AdminDealProvider>().fetchAllDeals();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDealCard(
    BuildContext context,
    dynamic deal,
    Color primaryBlue,
    bool isDark,
  ) {
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    Color statusColor = Colors.orange;
    if (deal.stage == 'close') {
      statusColor = Colors.green;
    } else if (deal.stage == 'ongoing') {
      statusColor = Colors.blue;
    } else if (deal.dealStatus.toLowerCase() == 'verified') {
      statusColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DealManagementScreen(deal: deal)),
        ).then((_) {
          // Refresh when returning in case of updates
          context.read<AdminDealProvider>().fetchAllDeals();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryBlue.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "DEAL #${deal.id}",
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "L-${deal.leadId}",
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        deal.stage == 'close' || deal.dealStatus.toLowerCase() == 'verified'
                            ? Icons.check_circle
                            : (deal.stage == 'ongoing' ? Icons.play_circle_fill : Icons.pending),
                        size: 9,
                        color: statusColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (deal.stage == 'close' ? 'CLOSED' : (deal.stage == 'ongoing' ? 'ONGOING' : deal.dealStatus)).toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Client & Advisor details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.clientName,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 10, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Text(
                            "+91 ${deal.clientNumber}",
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "ADVISOR",
                        style: GoogleFonts.montserrat(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 10, color: Colors.amber.shade800),
                          const SizedBox(width: 2),
                          Text(
                            deal.advisorCode,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.withOpacity(0.1), height: 1),
            const SizedBox(height: 8),

            // Property & Token info Compact Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem("Property", "PROP-${deal.propertyId}", Icons.domain),
                _buildInfoItem(
                  "Token",
                  (deal.tokenAmount != null && deal.tokenAmount != '0' && deal.tokenAmount != '')
                      ? "₹${deal.tokenAmount}"
                      : "Pending",
                  Icons.monetization_on,
                ),
                _buildInfoItem("Date", deal.createdAt.split(' ')[0], Icons.calendar_today),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.grey[500]),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
