import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_team_provider.dart';
import '../../data/models/team_models.dart';
import 'broker_profile_screen.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTeamProvider>().fetchTeam();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminTeamProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              labelColor: primaryBlue,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'Tree View'),
                Tab(text: 'List View'),
              ],
            ),
          ),
        ),
      ),
      body: provider.isLoading || provider.teamTree == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Tree View (Custom Org Chart)
                InteractiveViewer(
                  // Allows zooming and panning the tree
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: _buildOrgChartNode(
                          provider.teamTree!,
                          primaryBlue,
                          isDark,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. List View
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: _flattenTree(provider.teamTree!)
                      .map((node) => _buildListTile(node, primaryBlue, isDark))
                      .toList(),
                ),
              ],
            ),
    );
  }

  // --- Org Chart Visual Builder ---
  Widget _buildOrgChartNode(AdvisorNode node, Color primaryBlue, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Node Card
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BrokerProfileScreen(advisorId: node.id),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryBlue.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  node.name,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CODE: ${node.code}',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (node.children.isNotEmpty) ...[
          // Vertical line down from parent
          Container(width: 2, height: 20, color: Colors.grey[400]),
          // Horizontal line connecting children
          Row(
            mainAxisSize: MainAxisSize.min,
            children: node.children.asMap().entries.map((entry) {
              int index = entry.key;
              bool isFirst = index == 0;
              bool isLast = index == node.children.length - 1;
              bool isOnly = node.children.length == 1;

              return Column(
                children: [
                  Row(
                    children: [
                      // Left branch
                      Container(
                        width: 40,
                        height: 2,
                        color: isFirst || isOnly
                            ? Colors.transparent
                            : Colors.grey[400],
                      ),
                      // Center drop
                      Container(width: 2, height: 20, color: Colors.grey[400]),
                      // Right branch
                      Container(
                        width: 40,
                        height: 2,
                        color: isLast || isOnly
                            ? Colors.transparent
                            : Colors.grey[400],
                      ),
                    ],
                  ),
                  // Recursive call for child
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildOrgChartNode(entry.value, primaryBlue, isDark),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // --- List View Builder ---
  Widget _buildListTile(AdvisorNode node, Color primaryBlue, bool isDark) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrokerProfileScreen(advisorId: node.id),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      tileColor: isDark ? Colors.grey[900] : Colors.white,
      leading: CircleAvatar(
        backgroundColor: Colors.blue[50],
        child: Text(
          node.name.substring(0, 1),
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        node.name,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        '${node.role} • ${node.code}',
        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  // Helper to turn tree into flat list
  List<AdvisorNode> _flattenTree(AdvisorNode node) {
    List<AdvisorNode> list = [node];
    for (var child in node.children) {
      list.addAll(_flattenTree(child));
    }
    return list;
  }
}
