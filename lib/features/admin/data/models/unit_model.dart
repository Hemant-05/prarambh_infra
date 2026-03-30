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
    );
  }
}