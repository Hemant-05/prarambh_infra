class DocumentModel {
  final String id;
  final String name;
  final String category;
  final String type; // 'PDF' or 'IMAGE'
  final String url;
  final String? userId;
  final String lastUpdated;

  DocumentModel({
    required this.id, required this.name, required this.category,
    required this.type, required this.url, required this.lastUpdated,
    this.userId,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    const String imageBaseUrl = "https://workiees.com/";

    // Safely parse URL
    String rawPath = json['file_path']?.toString() ?? '';
    String fullUrl = rawPath.startsWith('http')
        ? rawPath
        : imageBaseUrl + (rawPath.startsWith('/') ? rawPath.substring(1) : rawPath);

    // Determine type from extension
    String fileType = fullUrl.toLowerCase().endsWith('.pdf') ? 'PDF' : 'IMAGE';

    // Format date nicely (e.g., "2026-03-27")
    String date = json['created_at']?.toString().split(' ')[0] ?? 'Unknown Date';

    return DocumentModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] == 'null' || json['name'] == null ? 'Unnamed Document' : json['name'],
      category: json['category'] ?? 'General',
      type: fileType,
      url: fullUrl,
      lastUpdated: date,
      userId: json['user_id']?.toString(),
    );
  }
}