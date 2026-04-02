import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:graphview/GraphView.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_team_provider.dart';
import '../../data/models/advisor_team_model.dart';

class AdvisorTeamScreen extends StatefulWidget {
  const AdvisorTeamScreen({super.key});

  @override
  State<AdvisorTeamScreen> createState() => _AdvisorTeamScreenState();
}

class _AdvisorTeamScreenState extends State<AdvisorTeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration algorithmConfig = BuchheimWalkerConfiguration();

  final TransformationController _transformController = TransformationController();
  final GlobalKey _rootNodeKey = GlobalKey();
  final GlobalKey _viewerKey = GlobalKey();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _currentLayoutType = 0;
  bool _graphInitialized = false;
  bool _showTreeFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    algorithmConfig
      ..siblingSeparation = 40
      ..levelSeparation = 100
      ..subtreeSeparation = 40
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    _tabController.addListener(() {
      if (mounted) setState(() => _showTreeFab = _tabController.index == 0);
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorId = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      if (advisorId.isNotEmpty) {
        context.read<AdvisorTeamProvider>().fetchTeamTree(advisorId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _generateGraphElements(AdvisorTeamNode rootNode) {
    graph.nodes.clear();
    graph.edges.clear();

    void traverse(AdvisorTeamNode current, Node? parentGNode) {
      final currentGNode = Node.Id(current);
      if (parentGNode != null) graph.addEdge(parentGNode, currentGNode);
      for (var child in current.children) {
        traverse(child, currentGNode);
      }
    }

    traverse(rootNode, null);
    _graphInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnRoot());
    });
  }

  void _centerOnRoot() {
    if (!mounted) return;
    _transformController.value = Matrix4.identity();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rootBox = _rootNodeKey.currentContext?.findRenderObject() as RenderBox?;
      final viewerBox = _viewerKey.currentContext?.findRenderObject() as RenderBox?;

      if (rootBox == null || viewerBox == null) return;

      final Offset rootPosInViewer = rootBox.localToGlobal(Offset.zero, ancestor: viewerBox);
      final Size rootSize = rootBox.size;
      final Size viewerSize = viewerBox.size;

      const double topPadding = 40.0;
      final double dx = viewerSize.width / 2 - rootPosInViewer.dx - rootSize.width / 2;
      final double dy = topPadding - rootPosInViewer.dy;

      _transformController.value = Matrix4.identity()..translate(dx, dy);
    });
  }

  void _changeLayout(int index) {
    setState(() {
      _currentLayoutType = index;
      switch (index) {
        case 0: algorithmConfig.orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM; break;
        case 1: algorithmConfig.orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT; break;
        case 2: algorithmConfig.orientation = BuchheimWalkerConfiguration.ORIENTATION_BOTTOM_TOP; break;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnRoot());
    });
  }

  List<AdvisorTeamNode> _flattenTree(AdvisorTeamNode node) {
    final List<AdvisorTeamNode> list = [];
    list.add(node); // Includes root
    for (final child in node.children) {
      list.addAll(_flattenTree(child));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final provider = context.watch<AdvisorTeamProvider>();

    if (provider.teamTree != null && !_graphInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_graphInitialized) setState(() => _generateGraphElements(provider.teamTree!));
      });
    }

    List<AdvisorTeamNode> flatList = [];
    if (provider.teamTree != null) {
      flatList = _flattenTree(provider.teamTree!);
      if (_searchQuery.isNotEmpty) {
        flatList = flatList.where((n) =>
        n.fullName.toLowerCase().contains(_searchQuery) ||
            n.advisorCode.toLowerCase().contains(_searchQuery) ||
            n.designation.toLowerCase().contains(_searchQuery)
        ).toList();
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // THE FIX: Bottom-Left root button
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _showTreeFab && _graphInitialized
          ? FloatingActionButton(
        onPressed: _centerOnRoot,
        backgroundColor: primaryBlue,
        elevation: 4,
        tooltip: 'Center on Root',
        child: const Icon(Icons.my_location, color: Colors.white),
      )
          : null,
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.montserrat(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search member by name, code or role...',
                hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey, size: 18), onPressed: () { _searchController.clear(); FocusScope.of(context).unfocus(); })
                    : null,
                filled: true, 
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.getBorderColor(context))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.getBorderColor(context))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
              ),
            ),
          ),

          // 2. Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.getBorderColor(context))),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.account_tree, size: 16), SizedBox(width: 8), Text('Tree View')])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.list_alt, size: 16), SizedBox(width: 8), Text('List View')])),
              ],
            ),
          ),

          // 3. Tab Views
          Expanded(
            child: provider.isLoading || provider.teamTree == null || !_graphInitialized
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // --- TAB 1: TREE VIEW ---
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.getBorderColor(context)))),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Row(
                          children: [
                            _chip(context, "Top-Down", Icons.arrow_downward, 0, primaryBlue, isDark), const SizedBox(width: 10),
                            _chip(context, "Left-Right", Icons.arrow_forward, 1, primaryBlue, isDark), const SizedBox(width: 10),
                            _chip(context, "Bottom-Up", Icons.arrow_upward, 2, primaryBlue, isDark),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      key: _viewerKey,
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        constrained: false,
                        boundaryMargin: const EdgeInsets.all(1500),
                        minScale: 0.1,
                        maxScale: 3.5,
                        child: GraphView(
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(algorithmConfig, TreeEdgeRenderer(algorithmConfig)),
                          paint: Paint()
                            ..color = primaryBlue.withOpacity(0.4)
                            ..strokeWidth = 2.0
                            ..strokeCap = StrokeCap.round
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) => _buildNodeWidget(context, node.key!.value as AdvisorTeamNode, primaryBlue, isDark),
                        ),
                      ),
                    ),
                  ],
                ),

                // --- TAB 2: LIST VIEW ---
                flatList.isEmpty
                    ? Center(child: Text("No members found.", style: GoogleFonts.montserrat(color: Colors.grey)))
                    : RefreshIndicator(
                      onRefresh: () {
                        final advisorId = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
                        return provider.fetchTeamTree(advisorId);
                      },
                      child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: flatList.length,
                          itemBuilder: (context, index) => _buildListCard(context, flatList[index], primaryBlue, isDark),
                        ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _chip(BuildContext context, String title, IconData icon, int index, Color blue, bool isDark) {
    final bool sel = _currentLayoutType == index;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;

    return GestureDetector(
      onTap: () => _changeLayout(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? blue : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? blue : AppColors.getBorderColor(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: sel ? Colors.white : secondaryTextColor),
            const SizedBox(width: 5),
            Text(title, style: GoogleFonts.montserrat(fontWeight: sel ? FontWeight.bold : FontWeight.w600, fontSize: 12, color: sel ? Colors.white : secondaryTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, AdvisorTeamNode node, Color blue, bool isDark) {
    final authProvider = context.read<AuthProvider>();
    final isRoot = node.advisorCode == authProvider.currentUser?.advisorCode;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    final bool isMatch = _searchQuery.isNotEmpty && (node.fullName.toLowerCase().contains(_searchQuery) || node.advisorCode.toLowerCase().contains(_searchQuery) || node.designation.toLowerCase().contains(_searchQuery));

    String initials = '?';
    final parts = node.fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isNotEmpty) initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : parts[0][0].toUpperCase();

    final Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRoot ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4FF)) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMatch ? Colors.orange : (isRoot ? blue : blue.withOpacity(0.25)), width: isMatch ? 3.0 : (isRoot ? 2.0 : 1.0)),
        boxShadow: [BoxShadow(color: isMatch ? Colors.orange.withOpacity(0.5) : (isRoot ? blue.withOpacity(0.18) : Colors.black.withOpacity(0.05)), blurRadius: isMatch ? 15 : (isRoot ? 16 : 8), offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: isMatch ? Colors.orange : blue.withOpacity(0.4), width: 1.5)),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isMatch ? Colors.orange.withOpacity(0.1) : blue.withOpacity(0.1),
              backgroundImage: node.profilePhoto.isNotEmpty ? NetworkImage(node.profilePhoto) : null,
              child: node.profilePhoto.isEmpty ? Text(initials, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: isMatch ? Colors.orange : blue, fontSize: 13)) : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(node.fullName, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 11, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(node.designation, style: GoogleFonts.montserrat(fontSize: 9, color: secondaryTextColor)),
          const SizedBox(height: 2),
          Text('#${node.advisorCode}', style: GoogleFonts.montserrat(fontSize: 10, color: isMatch ? Colors.orange : blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );

    if (isRoot) return KeyedSubtree(key: _rootNodeKey, child: card);
    return card;
  }

  Widget _buildListCard(BuildContext context, AdvisorTeamNode node, Color blue, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    String initials = '?';
    final parts = node.fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isNotEmpty) initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : parts[0][0].toUpperCase();

    Color statusBg = Colors.grey.shade100;
    Color statusText = Colors.grey.shade700;
    if (node.status.toLowerCase() == 'active') { statusBg = Colors.green.shade50; statusText = Colors.green.shade700; }
    else if (node.status.toLowerCase() == 'pending') { statusBg = Colors.orange.shade50; statusText = Colors.orange.shade800; }
    else if (node.status.toLowerCase() == 'inactive') { statusBg = Colors.red.shade50; statusText = Colors.red.shade700; }

    if (isDark) {
        statusBg = statusText.withOpacity(0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: blue.withOpacity(0.1),
            backgroundImage: node.profilePhoto.isNotEmpty ? NetworkImage(node.profilePhoto) : null,
            child: node.profilePhoto.isEmpty ? Text(initials, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: blue, fontSize: 16)) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                const SizedBox(height: 4),
                Text('#${node.advisorCode}', style: GoogleFonts.montserrat(fontSize: 11, color: blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: secondaryTextColor),
                    const SizedBox(width: 4),
                    Text('Joined ${node.createdAt}', style: GoogleFonts.montserrat(fontSize: 10, color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(node.designation.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 9, color: blue, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: statusText.withOpacity(0.2))),
                child: Text(node.status.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 9, color: statusText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}