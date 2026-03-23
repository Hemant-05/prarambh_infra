class UnitModel {
  final String id;
  final String unitNumber; // e.g., '101'
  final String type; // '2BHK', '3BHK'
  final String price; // '₹45L'
  final String status; // 'AVAILABLE', 'BOOKED', 'SOLD'
  final String superArea;
  final String facing;
  final String floor;
  final List<String> features;
  final Map<String, String> pricingBreakdown;
  final String totalCost;

  UnitModel({
    required this.id, required this.unitNumber, required this.type,
    required this.price, required this.status, required this.superArea,
    required this.facing, required this.floor, required this.features,
    required this.pricingBreakdown, required this.totalCost,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString() ?? '',
      unitNumber: json['unit_number'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      superArea: json['super_area'] ?? '',
      facing: json['facing'] ?? '',
      floor: json['floor'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      pricingBreakdown: Map<String, String>.from(json['pricing_breakdown'] ?? {}),
      totalCost: json['total_cost'] ?? '',
    );
  }
}