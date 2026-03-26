class UnitModel {
  final int id;
  final int projectId;

  // Identification
  final String towerName;
  final String unitNumber;
  final String configuration; // 2BHK, 3BHK
  final String propertyType;
  final String saleCategory;

  // Location
  final String floorNumber;
  final String facing;
  final String location;
  final String plotNumber;
  final String plotDimensions;

  // Area & Pricing
  final double areaSqft;
  final double ratePerSqft;
  final double basePrice;

  // Availability
  final String availabilityStatus;

  UnitModel({
    required this.id,
    required this.projectId,
    required this.towerName,
    required this.unitNumber,
    required this.configuration,
    required this.propertyType,
    required this.saleCategory,
    required this.floorNumber,
    required this.facing,
    required this.location,
    required this.plotNumber,
    required this.plotDimensions,
    required this.areaSqft,
    required this.ratePerSqft,
    required this.basePrice,
    required this.availabilityStatus,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,

      towerName: json['tower_name'] ?? '',
      unitNumber: json['unit_number'] ?? '',
      configuration: json['configuration'] ?? '',
      propertyType: json['property_type'] ?? '',
      saleCategory: json['sale_category'] ?? '',

      floorNumber: json['floor_number'] ?? '',
      facing: json['facing'] ?? '',
      location: json['Location'] ?? '',
      plotNumber: json['plot_number'] ?? '',
      plotDimensions: json['plot_dimensions'] ?? '',

      areaSqft: double.tryParse(json['area_sqft']?.toString() ?? '0') ?? 0,
      ratePerSqft: double.tryParse(json['rate_per_sqft']?.toString() ?? '0') ?? 0,
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0,

      availabilityStatus: json['availability_status'] ?? 'Available',
    );
  }
}