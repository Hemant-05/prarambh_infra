import 'package:prarambh_infra/features/admin/data/models/unit_model.dart';

class InventoryFilterState {
  String type;
  String configuration;
  String saleCategory;
  String facing;
  String location;
  double? minArea;
  double? maxArea;
  double? minRate;
  double? maxRate;

  InventoryFilterState({
    this.type = 'All',
    this.configuration = 'All',
    this.saleCategory = 'All',
    this.facing = 'All',
    this.location = 'All',
    this.minArea,
    this.maxArea,
    this.minRate,
    this.maxRate,
  });

  bool get isActive =>
      type != 'All' ||
      configuration != 'All' ||
      saleCategory != 'All' ||
      facing != 'All' ||
      location != 'All' ||
      minArea != null ||
      maxArea != null ||
      minRate != null ||
      maxRate != null;

  void reset() {
    type = 'All';
    configuration = 'All';
    saleCategory = 'All';
    facing = 'All';
    location = 'All';
    minArea = null;
    maxArea = null;
    minRate = null;
    maxRate = null;
  }

  List<UnitModel> apply(List<UnitModel> units) {
    return units.where((unit) {
      final matchesType = type == 'All' ||
          unit.propertyType.toLowerCase() == type.toLowerCase();
      final matchesConfig = configuration == 'All' ||
          unit.configuration.toLowerCase() == configuration.toLowerCase();
      final matchesCategory = saleCategory == 'All' ||
          unit.saleCategory.toLowerCase() == saleCategory.toLowerCase();
      final matchesFacing = facing == 'All' ||
          unit.facing.toLowerCase() == facing.toLowerCase();
      final matchesLocation = location == 'All' ||
          unit.location.toLowerCase() == location.toLowerCase();
      final matchesArea = (minArea == null || unit.areaSqft >= minArea!) &&
          (maxArea == null || unit.areaSqft <= maxArea!);
      final matchesRate = (minRate == null || unit.ratePerSqft >= minRate!) &&
          (maxRate == null || unit.ratePerSqft <= maxRate!);

      return matchesType &&
          matchesConfig &&
          matchesCategory &&
          matchesFacing &&
          matchesLocation &&
          matchesArea &&
          matchesRate;
    }).toList();
  }
}
