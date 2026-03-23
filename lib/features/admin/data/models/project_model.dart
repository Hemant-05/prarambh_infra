class ProjectModel {
  final String id;
  final String name;
  final String developer;
  final String location;
  final String reraNo;
  final String area;
  final String totalUnits;
  final String baseRate;
  final String status; // 'RERA APPROVED', 'NEW LAUNCH', 'FEW LEFT'
  final String imageUrl;

  ProjectModel({
    required this.id, required this.name, required this.developer,
    required this.location, required this.reraNo, required this.area,
    required this.totalUnits, required this.baseRate, required this.status,
    required this.imageUrl,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '', name: json['name'] ?? '',
      developer: json['developer'] ?? '', location: json['location'] ?? '',
      reraNo: json['rera_no'] ?? '', area: json['area'] ?? '',
      totalUnits: json['total_units']?.toString() ?? '',
      baseRate: json['base_rate'] ?? '', status: json['status'] ?? 'NEW',
      imageUrl: json['image_url'] ?? '',
    );
  }
}