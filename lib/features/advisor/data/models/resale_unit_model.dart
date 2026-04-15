class ResaleUnitModel {
  final int id;
  final int projectId;
  final String towerName;
  final String floorNumber;
  final String unitNumber;
  final String configuration;
  final String propertyType;
  final String saleCategory;
  final String facing;
  final String plotNumber;
  final String plotDimensions;
  final String areaSqft;
  final String ratePerSqft;
  final String availabilityStatus;
  final String colonyName;
  final List<String> unitImages;

  ResaleUnitModel({
    required this.id,
    required this.projectId,
    required this.towerName,
    required this.floorNumber,
    required this.unitNumber,
    required this.configuration,
    required this.propertyType,
    required this.saleCategory,
    required this.facing,
    required this.plotNumber,
    required this.plotDimensions,
    required this.areaSqft,
    required this.ratePerSqft,
    required this.availabilityStatus,
    required this.colonyName,
    required this.unitImages,
  });

  factory ResaleUnitModel.fromJson(Map<String, dynamic> json) {
    return ResaleUnitModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      towerName: json['tower_name']?.toString() ?? '',
      floorNumber: json['floor_number']?.toString() ?? '',
      unitNumber: json['unit_number']?.toString() ?? '',
      configuration: json['configuration']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      saleCategory: json['sale_category']?.toString() ?? '',
      facing: json['facing']?.toString() ?? '',
      plotNumber: json['plot_number']?.toString() ?? '',
      plotDimensions: json['plot_dimensions']?.toString() ?? '',
      areaSqft: json['area_sqft']?.toString() ?? '0',
      ratePerSqft: json['rate_per_sqft']?.toString() ?? '0',
      availabilityStatus: json['availability_status']?.toString() ?? '',
      colonyName: json['colony_name']?.toString() ?? '',
      unitImages: (json['unit_images'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  double get totalValue {
    final area = double.tryParse(areaSqft) ?? 0;
    final rate = double.tryParse(ratePerSqft) ?? 0;
    return area * rate;
  }

  bool get isAvailable =>
      availabilityStatus.toLowerCase() == 'available';
}
