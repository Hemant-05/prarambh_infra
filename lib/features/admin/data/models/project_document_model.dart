class ProjectDocumentModel {
  final String id;
  final String title;
  final String category; // 'Project Site Maps', 'Project Brochures', etc.
  final String type; // 'PDF', 'JPG'
  final String size;
  final String lastUpdated;

  ProjectDocumentModel({
    required this.id, required this.title, required this.category,
    required this.type, required this.size, required this.lastUpdated,
  });

  factory ProjectDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      type: json['type'] ?? 'PDF',
      size: json['size'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}