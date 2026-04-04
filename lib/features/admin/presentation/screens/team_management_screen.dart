import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:graphview/GraphView.dart';
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
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration algorithmConfig = BuchheimWalkerConfiguration();

  /// Controls the pan/zoom of the GraphView canvas
  final TransformationController _transformController =
      TransformationController();

  /// Key placed on the root node widget — lets us read its real render position
  final GlobalKey _rootNodeKey = GlobalKey();

  /// Key placed on the Expanded that wraps InteractiveViewer — lets us read viewport size
  final GlobalKey _viewerKey = GlobalKey();

  // --- NEW: Search Implementation ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _currentLayoutType = 0;
  bool _graphInitialized = false;
  bool _showTreeFab = true; // FAB only visible on Tree View tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    algorithmConfig
      ..siblingSeparation = 30
      ..levelSeparation = 100
      ..subtreeSeparation = 30
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    // Show FAB only on tree tab
    _tabController.addListener(() {
      if (mounted) setState(() => _showTreeFab = _tabController.index == 0);
    });

    // --- NEW: Listen to search changes ---
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTeamProvider>().fetchTeam();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    _transformController.dispose();
    _searchController.dispose(); // NEW: Dispose search controller
    super.dispose();
  }

  void _generateGraphElements(AdvisorNode rootNode) {
    graph.nodes.clear();
    graph.edges.clear();

    void traverse(AdvisorNode current, Node? parentGNode) {
      final currentGNode = Node.Id(current);
      if (parentGNode != null) {
        graph.addEdge(parentGNode, currentGNode);
      }
      for (var child in current.children) {
        traverse(child, currentGNode);
      }
    }

    traverse(rootNode, null);
    _graphInitialized = true;

    // Wait for two frames: first frame lays out the graph, second we can read positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnRoot());
    });
  }

  void _centerOnRoot() {
    if (!mounted) return;

    // Step 1 — reset to identity
    _transformController.value = Matrix4.identity();

    // Step 2 — read positions after identity is applied
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final rootBox =
          _rootNodeKey.currentContext?.findRenderObject() as RenderBox?;
      final viewerBox =
          _viewerKey.currentContext?.findRenderObject() as RenderBox?;

      if (rootBox == null || viewerBox == null) return;

      // Root node position in viewer's local coordinate space (with identity transform)
      final Offset rootPosInViewer = rootBox.localToGlobal(
        Offset.zero,
        ancestor: viewerBox,
      );
      final Size rootSize = rootBox.size;
      final Size viewerSize = viewerBox.size;

      // We want the root node to appear centered horizontally
      // and 24px below the top of the visible viewer area
      const double topPadding = 24.0;
      final double dx =
          viewerSize.width / 2 - rootPosInViewer.dx - rootSize.width / 2;
      final double dy = topPadding - rootPosInViewer.dy;

      _transformController.value = Matrix4.identity()..translate(dx, dy);
    });
  }

  void _changeLayout(int index) {
    setState(() {
      _currentLayoutType = index;
      switch (index) {
        case 0:
          algorithmConfig.orientation =
              BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
          break;
        case 1:
          algorithmConfig.orientation =
              BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;
          break;
        case 2:
          algorithmConfig.orientation =
              BuchheimWalkerConfiguration.ORIENTATION_BOTTOM_TOP;
          break;
      }
    });
    // Re-center after layout algorithm changes (graph is re-drawn next frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnRoot());
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminTeamProvider>();

    if (provider.teamTree != null && !_graphInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_graphInitialized) {
          setState(() => _generateGraphElements(provider.teamTree!));
        }
      });
    }

    // --- NEW: Filter list for the List View Tab ---
    List<AdvisorNode> flatList = [];
    if (provider.teamTree != null) {
      flatList = _flattenTree(provider.teamTree!);
      if (_searchQuery.isNotEmpty) {
        flatList = flatList.where((n) {
          return n.name.toLowerCase().contains(_searchQuery) ||
              n.code.toLowerCase().contains(_searchQuery) ||
              n.role.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      floatingActionButton: _showTreeFab && _graphInitialized
          ? FloatingActionButton(
              onPressed: _centerOnRoot,
              backgroundColor: primaryBlue,
              tooltip: 'Center on Root',
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
      appBar: AppBar(
        backgroundColor: primaryBlue,
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
                border: Border.all(
                  color: primaryBlue.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: primaryBlue.withOpacity(0.1), blurRadius: 8),
                ],
              ),
              labelColor: primaryBlue,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_tree, size: 16),
                      SizedBox(width: 8),
                      Text('Tree View'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 16),
                      SizedBox(width: 8),
                      Text('List View'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- NEW: Unified Search Bar ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.montserrat(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, code or role...',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue),
                ),
              ),
            ),
          ),

          // --- Rest of the Content ---
          Expanded(
            child:
                provider.isLoading ||
                    provider.teamTree == null ||
                    !_graphInitialized
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // ── Tab 1: GraphView Tree ─────────────────────────────────
                      Column(
                        children: [
                          // Layout chips
                          Container(
                            height: 58,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  _chip(
                                    "Top-Down",
                                    Icons.arrow_downward,
                                    0,
                                    primaryBlue,
                                    isDark,
                                  ),
                                  const SizedBox(width: 10),
                                  _chip(
                                    "Left-Right",
                                    Icons.arrow_forward,
                                    1,
                                    primaryBlue,
                                    isDark,
                                  ),
                                  const SizedBox(width: 10),
                                  _chip(
                                    "Bottom-Up",
                                    Icons.arrow_upward,
                                    2,
                                    primaryBlue,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Graph Canvas — key lets us read the viewport size
                          Expanded(
                            key: _viewerKey,
                            child: InteractiveViewer(
                              transformationController: _transformController,
                              constrained: false,
                              boundaryMargin: const EdgeInsets.all(800),
                              minScale: 0.08,
                              maxScale: 3.5,
                              child: GraphView(
                                graph: graph,
                                algorithm: BuchheimWalkerAlgorithm(
                                  algorithmConfig,
                                  TreeEdgeRenderer(algorithmConfig),
                                ),
                                paint: Paint()
                                  ..color = primaryBlue.withOpacity(0.4)
                                  ..strokeWidth = 1.8
                                  ..strokeCap = StrokeCap.round
                                  ..style = PaintingStyle.stroke,
                                builder: (Node node) {
                                  final advisorNode =
                                      node.key!.value as AdvisorNode;
                                  return _buildNodeWidget(
                                    advisorNode,
                                    primaryBlue,
                                    isDark,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Tab 2: List View ─────────────────────────────────────
                      flatList.isEmpty
                          ? Center(
                              child: Text(
                                "No advisors found.",
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.all(20),
                              children: flatList
                                  .map(
                                    (n) =>
                                        _buildListCard(n, primaryBlue, isDark),
                                  )
                                  .toList(),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Layout chip ───────────────────────────────────────────────────────────

  Widget _chip(
    String title,
    IconData icon,
    int index,
    Color blue,
    bool isDark,
  ) {
    final bool sel = _currentLayoutType == index;
    return GestureDetector(
      onTap: () => _changeLayout(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? blue : (isDark ? Colors.grey[850] : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? blue : Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: sel
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: sel ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
                color: sel
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Graph node card ───────────────────────────────────────────────────────

  Widget _buildNodeWidget(AdvisorNode node, Color blue, bool isDark) {
    final bool isRoot = node.id == 'root';

    // --- NEW: Match Logic for Highlight ---
    final bool isMatch =
        _searchQuery.isNotEmpty &&
        (node.name.toLowerCase().contains(_searchQuery) ||
            node.code.toLowerCase().contains(_searchQuery) ||
            node.role.toLowerCase().contains(_searchQuery));

    // Build initials safely
    String initials = '?';
    final String trimmed = node.name.trim();
    if (trimmed.isNotEmpty) {
      final parts = trimmed.split(' ').where((s) => s.isNotEmpty).toList();
      initials = parts.length > 1
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }

    final Widget card = GestureDetector(
      onTap: isRoot
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BrokerProfileScreen(advisorId: node.id),
              ),
            ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRoot
              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4FF))
              : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(16),
          // --- NEW: Border Highlight ---
          border: Border.all(
            color: isMatch
                ? Colors.orange
                : (isRoot ? blue : blue.withOpacity(0.25)),
            width: isMatch ? 3.0 : (isRoot ? 2.0 : 1.0),
          ),
          // --- NEW: Glow Shadow ---
          boxShadow: [
            BoxShadow(
              color: isMatch
                  ? Colors.orange.withOpacity(0.5)
                  : (isRoot
                        ? blue.withOpacity(0.18)
                        : Colors.black.withOpacity(0.05)),
              blurRadius: isMatch ? 15 : (isRoot ? 16 : 8),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMatch ? Colors.orange : blue.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: isMatch
                    ? Colors.orange.withOpacity(0.1)
                    : blue.withOpacity(0.1),
                backgroundImage: node.avatarUrl.isNotEmpty
                    ? NetworkImage(node.avatarUrl)
                    : null,
                child: node.avatarUrl.isEmpty
                    ? Text(
                        initials,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: isMatch ? Colors.orange : blue,
                          fontSize: 13,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              node.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              node.role,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (!isRoot)
              Text(
                '• ${node.code}',
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  color: isMatch ? Colors.orange : blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (node.createdAt.isNotEmpty && !isRoot)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  node.createdAt,
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (node.children.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMatch
                      ? Colors.orange.withOpacity(0.1)
                      : blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${node.children.length} member${node.children.length == 1 ? '' : 's'}',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isMatch ? Colors.orange : blue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Wrap the root node with its GlobalKey so we can read its render position
    if (isRoot) return KeyedSubtree(key: _rootNodeKey, child: card);
    return card;
  }

  // ── List card ─────────────────────────────────────────────────────────────

  Widget _buildListCard(AdvisorNode node, Color blue, bool isDark) {
    String initials = '?';
    final String trimmed = node.name.trim();
    if (trimmed.isNotEmpty) {
      final parts = trimmed.split(' ').where((s) => s.isNotEmpty).toList();
      initials = parts.length > 1
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }

    return GestureDetector(
      onTap: node.id == 'root'
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BrokerProfileScreen(advisorId: node.id),
              ),
            ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: blue.withOpacity(0.1),
              backgroundImage: node.avatarUrl.isNotEmpty
                  ? NetworkImage(node.avatarUrl)
                  : null,
              child: node.avatarUrl.isEmpty
                  ? Text(
                      initials,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: blue,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.name,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          node.role,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${node.code}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (node.createdAt.isNotEmpty && node.id != 'root') ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Joined: ${node.createdAt}',
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${node.children.length}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                Text(
                  'Sub-Advisors',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  List<AdvisorNode> _flattenTree(AdvisorNode node) {
    final List<AdvisorNode> list = [];
    if (node.id != 'root') list.add(node);
    for (final child in node.children) {
      list.addAll(_flattenTree(child));
    }
    return list;
  }
}
