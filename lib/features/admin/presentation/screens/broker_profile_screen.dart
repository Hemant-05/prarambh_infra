import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_team_provider.dart';
import '../../data/models/team_models.dart';

class BrokerProfileScreen extends StatefulWidget {
  final String advisorId;
  const BrokerProfileScreen({super.key, required this.advisorId});

  @override
  State<BrokerProfileScreen> createState() => _BrokerProfileScreenState();
}

class _BrokerProfileScreenState extends State<BrokerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTeamProvider>().fetchProfile(widget.advisorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final provider = context.watch<AdminTeamProvider>();

    if (provider.isLoading || provider.selectedProfile == null) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final profile = provider.selectedProfile!;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: primaryBlue,
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: primaryBlue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      profile.name,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: ${profile.code}',
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Column(
                children: [
                  // Overlapping Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: const AssetImage(
                        'assets/images/logos.png',
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // Contact Info
                        _buildCard(cardColor, [
                          _buildContactRow(
                            Icons.phone,
                            'Mobile',
                            profile.phone,
                          ),
                          const Divider(),
                          _buildContactRow(Icons.email, 'Email', profile.email),
                          const Divider(),
                          _buildContactRow(
                            Icons.cake,
                            'Age',
                            '${profile.age} years',
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // My Team
                        _buildCard(cardColor, [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people, color: primaryBlue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'My Team',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Total: 15',
                                  style: GoogleFonts.montserrat(
                                    color: primaryBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: ['Savitri', 'Jyoti', 'Rahul', 'Amit']
                                  .map(
                                    (name) => Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            name,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Pipeline Stats
                        _buildCard(cardColor, [
                          Row(
                            children: [
                              Icon(Icons.bar_chart, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Pipeline Stats',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPipelineBox(
                                  profile.suspectCount,
                                  'SUSPECT',
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPipelineBox(
                                  profile.prospectCount,
                                  'PROSPECT',
                                  Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPipelineBox(
                                  profile.negotCount,
                                  'NEGOT.',
                                  Colors.indigo,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPipelineBox(
                                  profile.dealCount,
                                  'DEAL',
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Business Performance
                        _buildCard(cardColor, [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Business Performance',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPerfBox(
                                  'PERSONAL SALES',
                                  profile.personalSales,
                                  '4 Deals Closed',
                                  Icons.person_outline,
                                  primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPerfBox(
                                  'TEAM SALES',
                                  profile.teamSales,
                                  '18 Deals Closed',
                                  Icons.people_outline,
                                  primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Attendance Tracker (Simplified UI representation)
                        _buildCard(cardColor, [
                          Row(
                            children: [
                              Icon(Icons.calendar_month, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Attendance Tracker',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'October 2023 Overview',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Present',
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Absent',
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Placeholder for Calendar Grid
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('Calendar Heatmap View'),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Documents section
                        _buildCard(cardColor, [
                          Row(
                            children: [
                              Icon(Icons.folder, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Documents',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDocRow(
                            'Aadhar Card',
                            'Verified',
                            Colors.green,
                            true,
                          ),
                          const Divider(),
                          _buildDocRow(
                            'PAN Card',
                            'Verified',
                            Colors.green,
                            true,
                          ),
                          const Divider(),
                          _buildDocRow(
                            'Broker ID Card',
                            'Generated',
                            Colors.grey,
                            false,
                          ),
                          const Divider(),
                          _buildDocRow(
                            'Welcome Letter',
                            'Pending Sign',
                            Colors.orange,
                            false,
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Suspend Action
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.block, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SUSPEND ADVISOR',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Current Status: Active',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.green,
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
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Enter reason for status change...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Status',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
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

  // --- UI Helpers ---
  Widget _buildCard(Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[900], size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineBox(int count, String title, Color color) {
    return Container(
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfBox(
    String title,
    String amount,
    String subtitle,
    IconData icon,
    Color primaryBlue,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: primaryBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocRow(
    String title,
    String status,
    Color statusColor,
    bool verified,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.visibility, size: 16, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.upload, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
