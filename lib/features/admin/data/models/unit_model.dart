class UnitModel {
  final int id;
  final int projectId;

  final String towerName;
  final String floorNumber;
  final String unitNumber;
  final String configuration;
  final String propertyType;
  final String saleCategory;
  final String facing;
  final String location;
  final String plotNumber;
  final String plotDimensions;
  final double areaSqft;
  final double ratePerSqft;
  final String size;
  final String availabilityStatus;
  final List<String> unitImages;

  double get calculatedPrice => areaSqft * ratePerSqft;

  UnitModel({
    required this.id,
    required this.projectId,
    required this.towerName,
    required this.floorNumber,
    required this.unitNumber,
    required this.configuration,
    required this.propertyType,
    required this.saleCategory,
    required this.facing,
    required this.location,
    required this.plotNumber,
    required this.plotDimensions,
    required this.areaSqft,
    required this.ratePerSqft,
    required this.size,
    required this.availabilityStatus,
    this.unitImages = const [],
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      projectId: json['project_id'] != null ? int.tryParse(json['project_id'].toString()) ?? 0 : 0,
      towerName: json['tower_name']?.toString() ?? '',
      floorNumber: json['floor_number']?.toString() ?? '',
      unitNumber: json['unit_number']?.toString() ?? '',
      configuration: json['configuration']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      saleCategory: json['sale_category']?.toString() ?? '',
      facing: json['facing']?.toString() ?? '',
      location: json['Location']?.toString() ?? json['location']?.toString() ?? '',
      plotNumber: json['plot_number']?.toString() ?? '',
      plotDimensions: json['plot_dimensions']?.toString() ?? '',
      areaSqft: double.tryParse(json['area_sqft']?.toString() ?? '0') ?? 0,
      ratePerSqft: double.tryParse(json['rate_per_sqft']?.toString() ?? '0') ?? 0,
      size: json['size']?.toString() ?? '',
      availabilityStatus: json['availability_status']?.toString() ?? 'Available',
      unitImages: _parseImages(json['unit_images']),
    );
  }

  static List<String> _parseImages(dynamic imagesData) {
    if (imagesData == null) return [];
    List<dynamic> items = [];
    if (imagesData is List) {
      items = imagesData;
    } else if (imagesData is String && imagesData.isNotEmpty) {
      // Handle comma-separated string just in case
      if (imagesData.contains(',')) {
        items = imagesData.split(',');
      } else {
        items = [imagesData];
      }
    }

    return items.map((img) {
      String url = img.toString().trim();
      // Backend returns relative paths like "uploads/units/..."
      if (!url.startsWith('http')) {
        return "https://workiees.com/" + (url.startsWith('/') ? url.substring(1) : url);
      }
      return url;
    }).toList();
  }
}