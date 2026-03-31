class AdvisorTeamNode {
  final String id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String profilePhoto;
  final String status;
  final String createdAt;
  final List<AdvisorTeamNode> children;

  AdvisorTeamNode({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.designation,
    required this.profilePhoto,
    required this.status,
    required this.createdAt,
    required this.children,
  });

  factory AdvisorTeamNode.fromJson(Map<String, dynamic> json) {
    var childrenList = json['children'] ?? json['team_members'] ?? [];

    return AdvisorTeamNode(
      id: json['id']?.toString() ?? '',
      advisorCode: json['Advisor_code']?.toString() ?? json['advisor_code']?.toString() ?? '',
      fullName: json['full_name'] ?? json['name'] ?? 'Unknown',
      designation: json['designation'] ?? json['role'] ?? 'Advisor',
      profilePhoto: _parseImageUrl(json['profile_photo'] ?? json['avatar_url']),
      status: json['status'] ?? 'Active',
      createdAt: json['created_at']?.toString().split(' ')[0] ?? '',
      children: (childrenList as List).map((e) => AdvisorTeamNode.fromJson(e)).toList(),
    );
  }

  static String _parseImageUrl(dynamic rawPath) {
    if (rawPath == null || rawPath.toString().isEmpty) return '';
    String path = rawPath.toString();
    const String baseUrl = "https://workiees.com/";
    // Ignore invalid files uploaded by accident during testing
    if (path.toLowerCase().endsWith('.xlsx') || path.toLowerCase().endsWith('.pdf')) return '';
    if (path.startsWith('http')) return path;
    return baseUrl + (path.startsWith('/') ? path.substring(1) : path);
  }
}