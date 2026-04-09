import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/assign_documents_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_team_provider.dart';

const String _baseUrl = 'https://workiees.com/';

class AdvisorProfileScreen extends StatefulWidget {
  final String advisorId;
  const AdvisorProfileScreen({super.key, required this.advisorId});

  @override
  State<AdvisorProfileScreen> createState() => _AdvisorProfileScreenState();
}

class _AdvisorProfileScreenState extends State<AdvisorProfileScreen> {
  final TextEditingController _suspendReasonCtrl = TextEditingController();
  bool _personalExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTeamProvider>().fetchProfile(widget.advisorId);
    });
  }

  @override
  void dispose() {
    _suspendReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final provider = context.watch<AdminTeamProvider>();

    if (provider.hasError && provider.selectedProfile == null) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: Center(
          child: UIHelper.buildInlineError(
            context: context,
            message: provider.errorMessage!,
            onRetry: () => provider.fetchProfile(widget.advisorId),
          ),
        ),
      );
    }

    if (provider.isLoading || provider.selectedProfile == null) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final p = provider.selectedProfile!;
    final bool isActive = p.status.toLowerCase() == 'active';
    final statusColor = isActive ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            backgroundColor: primaryBlue,
            expandedHeight: 210,
            pinned: true,
            leading: backButton(isDark: true),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryBlue, primaryBlue.withBlue(255)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                (p.profilePhoto != null &&
                                    p.profilePhoto!.isNotEmpty)
                                ? NetworkImage('$_baseUrl${p.profilePhoto}')
                                      as ImageProvider
                                : null,
                            child:
                                (p.profilePhoto == null ||
                                    p.profilePhoto!.isEmpty)
                                ? Text(
                                    p.initials,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.name,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ID: ${p.advisorCode}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Contact Info ──────────────────────────────────────
                  _card(cardColor, [
                    _infoRow(
                      Icons.phone_outlined,
                      'Mobile',
                      p.phone,
                      primaryBlue,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.email_outlined,
                      'Email',
                      p.email,
                      primaryBlue,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.work_outline,
                      'Designation',
                      p.designation,
                      primaryBlue,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.percent,
                      'Commission Slab',
                      '${double.tryParse(p.slab)!.toStringAsFixed(0)} ₹',
                      primaryBlue,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.badge_outlined,
                      'Advisor Type',
                      p.advisorType,
                      primaryBlue,
                      onTap: () => _showAdvisorTypePicker(context, p.id, p.advisorType),
                      trailing: Icon(Icons.edit_outlined, size: 16, color: primaryBlue.withOpacity(0.5)),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Personal Details (Collapsible) ─────────────────────
                  _card(cardColor, [
                    GestureDetector(
                      onTap: () => setState(
                        () => _personalExpanded = !_personalExpanded,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle(
                            Icons.person_outline,
                            'Personal Details',
                            primaryBlue,
                          ),
                          Icon(
                            _personalExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    if (_personalExpanded) ...[
                      const SizedBox(height: 16),
                      _infoRow(
                        Icons.people_outline,
                        'Father Name',
                        p.fatherName.isEmpty ? 'N/A' : p.fatherName,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.cake_outlined,
                        'Date of Birth',
                        p.dateOfBirth.isEmpty ? 'N/A' : p.dateOfBirth,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.wc,
                        'Gender',
                        p.gender.isEmpty ? 'N/A' : p.gender,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.home_outlined,
                        'Address',
                        '${p.address}, ${p.city}, ${p.state} - ${p.pincode}',
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.people_outline,
                        'Nominee',
                        '${p.nomineeName} (${p.relationship})',
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.account_balance_outlined,
                        'Bank',
                        '${p.bankName} • ${p.accountNumber}',
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(Icons.numbers, 'IFSC', p.ifscCode, primaryBlue),
                      _divider(),
                      _infoRow(
                        Icons.work_outline,
                        'Occupation',
                        p.occupation.isEmpty ? 'N/A' : p.occupation,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.phone_android,
                        'Nominee Phone',
                        p.nomineePhone.isEmpty ? 'N/A' : p.nomineePhone,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.credit_card,
                        'Aadhaar Number',
                        p.aadhaarNumber.isEmpty ? 'N/A' : p.aadhaarNumber,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.credit_card,
                        'PAN Number',
                        p.panNumber.isEmpty ? 'N/A' : p.panNumber,
                        primaryBlue,
                      ),
                    ],
                  ]),
                  const SizedBox(height: 16),

                  // ── My Team ────────────────────────────────────────────
                  _card(cardColor, [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(
                          Icons.people_outline,
                          'My Team',
                          primaryBlue,
                        ),
                        _badge('Total: ${p.myTeam.length}', primaryBlue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final filteredTeam = p.myTeam
                            .where(
                              (m) =>
                                  m.advisorCode.toLowerCase() != 'admin001' &&
                                  m.designation.toLowerCase() != 'admin',
                            )
                            .toList();

                        if (filteredTeam.isEmpty) {
                          return _emptyState('No team members yet');
                        }

                        return SizedBox(
                          height: 92,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredTeam.length,
                            itemBuilder: (_, i) {
                              final member = filteredTeam[i];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: primaryBlue.withOpacity(
                                        0.1,
                                      ),
                                      backgroundImage:
                                          (member.profilePhoto != null &&
                                              member.profilePhoto!.isNotEmpty)
                                          ? NetworkImage(
                                                  '$_baseUrl${member.profilePhoto}',
                                                )
                                                as ImageProvider
                                          : null,
                                      child:
                                          (member.profilePhoto == null ||
                                              member.profilePhoto!.isEmpty)
                                          ? Text(
                                              member.initials,
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: primaryBlue,
                                                fontSize: 14,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        member.fullName.trim().split(' ').first,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Leader Info ───────────────────────────────────────
                  if (p.leaderName != null && p.leaderName!.isNotEmpty) ...[
                    _card(cardColor, [
                      _sectionTitle(
                        Icons.assignment_ind_outlined,
                        'Leader Details',
                        primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      _infoRow(
                        Icons.person_pin_outlined,
                        'Leader Name',
                        p.leaderName!,
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.badge_outlined,
                        'Leader Code',
                        p.leaderCode ?? 'N/A',
                        primaryBlue,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.work_outline,
                        'Leader Designation',
                        p.leaderDesignation ?? 'N/A',
                        primaryBlue,
                      ),
                    ]),
                    const SizedBox(height: 16),
                  ],

                  // ── Pipeline Stats ─────────────────────────────────────
                  _card(cardColor, [
                    _sectionTitle(
                      Icons.bar_chart_outlined,
                      'Pipeline Stats',
                      primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    p.salesPipeline.isEmpty
                        ? _emptyState('No pipeline data')
                        : Row(
                            children: p.salesPipeline.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final colors = [
                                    Colors.blue,
                                    Colors.indigo,
                                    Colors.purple,
                                    Colors.orange,
                                    Colors.red,
                                  ];
                                  final color =
                                      colors[entry.key % colors.length];
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: _pipelineBox(
                                        entry.value.value,
                                        entry.value.key.toUpperCase(),
                                        color,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Business Performance ───────────────────────────────
                  _card(cardColor, [
                    _sectionTitle(
                      Icons.trending_up,
                      'Business Performance',
                      primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _perfBox(
                            'PERSONAL SALES',
                            '₹${p.personalSales.toStringAsFixed(0)}',
                            Icons.person_outline,
                            primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _perfBox(
                            'TEAM SALES',
                            '₹${p.teamSales.toStringAsFixed(0)}',
                            Icons.people_outline,
                            Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Attendance Tracker ─────────────────────────────────
                  _card(cardColor, [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(
                          Icons.calendar_month_outlined,
                          'Attendance Tracker',
                          primaryBlue,
                        ),
                        Row(
                          children: [
                            _legendDot(Colors.green, 'Present'),
                            const SizedBox(width: 8),
                            _legendDot(Colors.red, 'Absent'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    p.attendanceTracker.isEmpty
                        ? _emptyState('No attendance data')
                        : Column(
                            children: p.attendanceTracker.take(10).map((entry) {
                              final isPresent =
                                  entry.status.toLowerCase() == 'present';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: (isPresent ? Colors.green : Colors.red)
                                      .withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.date,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isPresent
                                                    ? Colors.green
                                                    : Colors.red)
                                                .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        entry.status,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isPresent
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryBlue.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Team Attendance",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _miniStat(
                                  'Total',
                                  '${p.teamAttendanceTotal}',
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _miniStat(
                                  'Present',
                                  '${p.teamAttendancePresent}',
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _miniStat(
                                  'Absent',
                                  '${p.teamAttendanceAbsent}',
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Documents ──────────────────────────────────────────
                  _card(cardColor, [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(
                          Icons.folder_outlined,
                          'Documents',
                          primaryBlue,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignDocumentsScreen(
                                  advisorId: p.id,
                                  advisorName: p.name,
                                  advisorCode: p.advisorCode,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Manage",
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (p.docAddressCardFront != null) ...[
                      _docRow('Aadhar Card (Front)', p.docAddressCardFront!),
                      _divider(),
                    ],
                    if (p.docAddressCardBack != null) ...[
                      _docRow('Aadhar Card (Back)', p.docAddressCardBack!),
                      _divider(),
                    ],
                    if (p.docPanCard != null) ...[
                      _docRow('PAN Card (Front)', p.docPanCard!),
                      _divider(),
                    ],
                    if (p.docPanCardBack != null) ...[
                      _docRow('PAN Card (Back)', p.docPanCardBack!),
                      if (p.otherFiles.isNotEmpty) _divider(),
                    ],
                    if (p.otherFiles.isEmpty &&
                        p.docAddressCardFront == null &&
                        p.docPanCard == null &&
                        p.docPanCardBack == null)
                      _emptyState('No documents uploaded'),
                    ...p.otherFiles.asMap().entries.map(
                      (e) => Column(
                        children: [
                          _docRow(
                            e.value.name == 'null'
                                ? 'Other Document'
                                : e.value.name,
                            e.value.filePath,
                          ),
                          if (e.key < p.otherFiles.length - 1) _divider(),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Achievements ───────────────────────────────────────
                  _card(cardColor, [
                    _sectionTitle(
                      Icons.military_tech_outlined,
                      'Achievements',
                      primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    p.achievements.isEmpty
                        ? _emptyState('No achievements yet')
                        : Column(
                            children: p.achievements
                                .map(
                                  (a) =>
                                      _achievementCard(a, primaryBlue, isDark),
                                )
                                .toList(),
                          ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Contests ───────────────────────────────────────────
                  _card(cardColor, [
                    _sectionTitle(
                      Icons.emoji_events_outlined,
                      'Active Contests',
                      primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    p.contests.isEmpty
                        ? _emptyState('No active contests')
                        : Column(
                            children: p.contests
                                .map(
                                  (c) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryBlue.withOpacity(0.05),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: primaryBlue.withOpacity(0.15),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.emoji_events,
                                            color: primaryBlue,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.title,
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Reward: ${c.rewardName}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                'Ends: ${c.endDate}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₹${c.selling}',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: primaryBlue,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              '${c.units} Units',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Upcoming Installments ──────────────────────────────
                  _card(cardColor, [
                    _sectionTitle(
                      Icons.payment_outlined,
                      'Upcoming Installments',
                      primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    p.upcomingInstallments.isEmpty
                        ? _emptyState('No upcoming installments')
                        : Column(
                            children: p.upcomingInstallments
                                .map(
                                  (inst) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          inst['title'] ?? 'Installment',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '₹${inst['amount'] ?? '0'}',
                                          style: GoogleFonts.montserrat(
                                            color: primaryBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Suspend / Update Status ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.block,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SUSPEND ADVISOR',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Current status badge
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: statusColor, size: 10),
                              const SizedBox(width: 8),
                              Text(
                                'Current Status: ${p.status}',
                                style: GoogleFonts.montserrat(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Suspension/Action Reason',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _suspendReasonCtrl,
                          maxLines: 3,
                          style: GoogleFonts.montserrat(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter reason for status change...',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[850]
                                : Colors.grey[50],
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status buttons row
                        Row(
                          children: [
                            Expanded(
                              child: _statusBtn(
                                label: 'Activate',
                                color: Colors.green,
                                icon: Icons.check_circle_outline,
                                onTap: () => _handleStatusChange(
                                  context,
                                  provider,
                                  'Active',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statusBtn(
                                label: 'Suspend',
                                color: Colors.red,
                                icon: Icons.block,
                                onTap: () => _handleStatusChange(
                                  context,
                                  provider,
                                  'Suspended',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusChange(
    BuildContext context,
    AdminTeamProvider provider,
    String newStatus,
  ) async {
    final reason = _suspendReasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason for status change'),
        ),
      );
      return;
    }
    final success = await provider.updateAdvisorStatus(
      widget.advisorId,
      newStatus,
      reason,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          success
              ? 'Status updated to $newStatus!'
              : 'Failed to update status. Try again.',
        ),
      ),
    );
    if (success) _suspendReasonCtrl.clear();
  }

  // ─── Helper Widgets ───────────────────────────────────────────────────────

  Widget _card(Color color, List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _sectionTitle(IconData icon, String title, Color color) => Row(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ],
  );

  Widget _infoRow(IconData icon, String label, String value, Color color, {VoidCallback? onTap, Widget? trailing}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      );

  void _showAdvisorTypePicker(BuildContext context, String advisorId, String currentType) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Advisor Type',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _typeOption(context, advisorId, 'Full Time', currentType == 'Full Time'),
              const SizedBox(height: 12),
              _typeOption(context, advisorId, 'Part Time', currentType == 'Part Time'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _typeOption(BuildContext context, String advisorId, String type, bool isSelected) {
    final primaryBlue = Theme.of(context).primaryColor;
    return InkWell(
      onTap: isSelected ? null : () async {
        Navigator.pop(context);
        final success = await context.read<AdminTeamProvider>().updateAdvisorType(advisorId, type);
        if (success && context.mounted) {
          UIHelper.showSuccess(context, 'Advisor type updated successfully');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              type,
              style: GoogleFonts.montserrat(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryBlue : null,
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 0.5);

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: GoogleFonts.montserrat(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _pipelineBox(int count, String title, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 8,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _perfBox(String title, String amount, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );

  Widget _legendDot(Color color, String label) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[600]),
      ),
    ],
  );

  Widget _miniStat(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey[600]),
        ),
      ],
    ),
  );

  Widget _docRow(String name, String filePath) {
    final fullUrl = '$_baseUrl$filePath';
    final ext = filePath.split('.').last.toLowerCase();
    final isImage = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(ext);
    final docIcon = isImage
        ? Icons.image_outlined
        : (ext == 'pdf' ? Icons.picture_as_pdf_outlined : Icons.attach_file);
    final iconColor = isImage
        ? Colors.blue
        : (ext == 'pdf' ? Colors.red : Colors.blueGrey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(docIcon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ext.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // View button
          GestureDetector(
            onTap: () => _openDocument(context, name, fullUrl, isImage),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Open externally button
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(fullUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot open this file')),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.open_in_new, size: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _openDocument(
    BuildContext context,
    String name,
    String url,
    bool isImage,
  ) {
    if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageViewerScreen(title: name, imageUrl: url),
        ),
      );
    } else {
      // Non-image: launch in browser
      launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      ).catchError((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot open this document')),
          );
        }
        return false;
      });
    }
  }

  Widget _emptyState(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: Text(
        msg,
        style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 13),
      ),
    ),
  );

  Widget _statusBtn({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _achievementCard(dynamic a, Color primaryBlue, bool isDark) {
    String title = 'Achievement';
    String type = 'General';
    String description = '';
    String time = '';

    if (a is Map) {
      title = a['title']?.toString() ?? 'Achievement';
      type = a['type']?.toString() ?? 'General';
      description = a['description']?.toString() ?? '';
      time =
          a['time']?.toString() ?? a['time_of_achievement']?.toString() ?? '';
    } else {
      title = a.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        _badge(type.toUpperCase(), Colors.amber),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -- Full-Screen Image Viewer --------------------------------------------------
class _ImageViewerScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  const _ImageViewerScreen({required this.title, required this.imageUrl});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  final TransformationController _controller = TransformationController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.white),
            tooltip: 'Reset Zoom',
            onPressed: () => _controller.value = Matrix4.identity(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            tooltip: 'Open Externally',
            onPressed: () async {
              final uri = Uri.parse(widget.imageUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            transformationController: _controller,
            minScale: 0.5,
            maxScale: 6.0,
            clipBehavior: Clip.none,
            child: Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _isLoading = false);
                    });
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                      });
                    }
                  });
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load image',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          if (!_isLoading && !_hasError)
            Positioned(
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pinch, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Pinch to zoom  �  Tap icon to open externally',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
