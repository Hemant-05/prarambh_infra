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

  // NEW: Automatically calculate the total price for the UI
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
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      towerName: json['tower_name'] ?? '',
      floorNumber: json['floor_number'] ?? '',
      unitNumber: json['unit_number'] ?? '',
      configuration: json['configuration'] ?? '',
      propertyType: json['property_type'] ?? '',
      saleCategory: json['sale_category'] ?? '',
      facing: json['facing'] ?? '',
      location: json['Location'] ?? '', // Capital L to match your JSON
      plotNumber: json['plot_number'] ?? '',
      plotDimensions: json['plot_dimensions'] ?? '',
      areaSqft: double.tryParse(json['area_sqft']?.toString() ?? '0') ?? 0,
      ratePerSqft: double.tryParse(json['rate_per_sqft']?.toString() ?? '0') ?? 0,
      size: json['size'] ?? '',
      availabilityStatus: json['availability_status'] ?? 'Available',
    );
  }
}