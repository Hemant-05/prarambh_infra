class ProjectModel {
  final int id;

  // Basic Info
  final String projectName;
  final String description;
  final String developerName;
  final String reraNumber;
  final String projectType;
  final String constructionStatus;
  final String status;

  // Location
  final String fullAddress;
  final String locationMapUrl;
  final String city;

  // Pricing & Size
  final double marketValue;
  final int totalPlots;
  final String buildArea;
  final String budgetRange;
  final double ratePerSqft;

  // Media
  final String videoUrl;
  final String brochureUrl;
  final String brochureFile;
  final List<String> images;

  // Extra
  final List<String> amenities;
  final List<String> specialties;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.projectName,
    required this.description,
    required this.developerName,
    required this.reraNumber,
    required this.projectType,
    required this.constructionStatus,
    required this.status,
    required this.fullAddress,
    required this.locationMapUrl,
    required this.city,
    required this.marketValue,
    required this.totalPlots,
    required this.buildArea,
    required this.budgetRange,
    required this.ratePerSqft,
    required this.videoUrl,
    required this.brochureUrl,
    required this.brochureFile,
    required this.images,
    required this.amenities,
    required this.specialties,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {

    // THE FIX: This helper function safely handles both Arrays and comma-separated Strings
    List<String> parseStringOrList(dynamic value) {
      if (value == null) return [];
      // If the backend sends a comma-separated string (e.g., "garden, pool")
      if (value is String) {
        if (value.trim().isEmpty) return [];
        return value.split(',').map((e) => e.trim()).toList();
      }
      // If the backend sends a proper JSON array
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProjectModel(
      id: json['id'] ?? 0,

      projectName: json['project_name'] ?? '',
      description: json['description'] ?? '',
      developerName: json['developer_name'] ?? '',
      reraNumber: json['rera_number'] ?? '',
      projectType: json['project_type'] ?? '',
      constructionStatus: json['construction_status'] ?? '',
      status: json['status'] ?? '',

      fullAddress: json['full_address'] ?? '',
      locationMapUrl: json['location'] ?? '',
      city: json['city'] ?? '',

      marketValue: double.tryParse(json['market_value']?.toString() ?? '0') ?? 0,
      totalPlots: int.tryParse(json['total_plots']?.toString() ?? '0') ?? 0,

      // Added .toString() here just in case backend sends numbers instead of strings
      buildArea: json['build_area']?.toString() ?? '',
      budgetRange: json['budget_range']?.toString() ?? '',
      ratePerSqft: double.tryParse(json['rate_per_sqft']?.toString() ?? '0') ?? 0,

      videoUrl: json['video_url'] ?? '',
      brochureUrl: json['brochure_url'] ?? '',
      brochureFile: json['brochure_file'] ?? '',

      // Apply the safe parser to the list fields
      images: parseStringOrList(json['images']),
      amenities: parseStringOrList(json['amenities']),
      specialties: parseStringOrList(json['specialties']),

      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}