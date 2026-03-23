import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/models/unit_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/admin_project_repository.dart';

class AdminProjectProvider extends ChangeNotifier {
  final AdminProjectRepository repository;
  AdminProjectProvider({required this.repository});

  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  List<UnitModel> _inventory = [];
  bool _isLoadingInventory = false;

  List<UnitModel> get inventory => _inventory;
  bool get isLoadingInventory => _isLoadingInventory;

  Future<void> fetchInventory(String projectId) async {
    _isLoadingInventory = true; notifyListeners();
    try {
      // _inventory = await repository.getProjectInventory(projectId);

      // Mock Data matching your Project Inventory screenshot
      await Future.delayed(const Duration(milliseconds: 400));
      _inventory = [
        UnitModel(id: '1', unitNumber: '101', type: '2BHK', price: '₹45L', status: 'AVAILABLE', superArea: '1250 sq. ft.', facing: 'East Facing', floor: '1st Floor', features: ['Modular Kitchen Fitted', 'Park View Balcony', 'Excellent Natural Light', 'Video Door Phone'], pricingBreakdown: {'Base Price': '₹42,00,000', 'PLC (Preferred Location)': '₹1,50,000', 'Club Membership': '₹1,00,000', 'Other Charges': '₹50,000'}, totalCost: '₹45,00,000'),
        UnitModel(id: '2', unitNumber: '102', type: '2BHK', price: '₹45L', status: 'BOOKED', superArea: '1250 sq. ft.', facing: 'West Facing', floor: '1st Floor', features: [], pricingBreakdown: {}, totalCost: ''),
        UnitModel(id: '3', unitNumber: '103', type: '3BHK', price: '₹65L', status: 'SOLD', superArea: '1600 sq. ft.', facing: 'North Facing', floor: '2nd Floor', features: [], pricingBreakdown: {}, totalCost: ''),
        UnitModel(id: '4', unitNumber: '104', type: '3BHK', price: '₹65L', status: 'AVAILABLE', superArea: '1600 sq. ft.', facing: 'South Facing', floor: '3rd Floor', features: [], pricingBreakdown: {}, totalCost: ''),
        UnitModel(id: '5', unitNumber: '201', type: '2BHK', price: '₹46L', status: 'AVAILABLE', superArea: '1250 sq. ft.', facing: 'East Facing', floor: '2nd Floor', features: [], pricingBreakdown: {}, totalCost: ''),
        UnitModel(id: '6', unitNumber: '202', type: '2BHK', price: '₹46L', status: 'BOOKED', superArea: '1250 sq. ft.', facing: 'West Facing', floor: '2nd Floor', features: [], pricingBreakdown: {}, totalCost: ''),
      ];
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoadingInventory = false; notifyListeners(); }
  }

  Future<void> fetchProjects() async {
    _isLoading = true; notifyListeners();
    try {
      // _projects = await repository.getAllProjects();

      // Mock Data matching your UI exactly
      await Future.delayed(const Duration(milliseconds: 500));
      _projects = [
        ProjectModel(id: '1', name: 'Shivangan Valley', developer: 'Bhutani Group', location: 'Sec-12, Green Avenue', reraNo: 'PRM/123/2023', area: '1200 Sq.ft', totalUnits: '45 Plots', baseRate: '₹2151/sq.ft', status: 'RERA APPROVED', imageUrl: 'url'),
        ProjectModel(id: '2', name: 'R K Nivash', developer: 'R K Builders', location: 'Highway Rd, Block B', reraNo: 'PRM/124/2023', area: '2400 Sq.ft', totalUnits: '12 Villas', baseRate: '₹4500/sq.ft', status: 'FEW LEFT', imageUrl: 'url'),
        ProjectModel(id: '3', name: 'Mangal Murti', developer: 'Mangal Group', location: 'Outer Ring Road', reraNo: 'PRM/125/2023', area: '900 Sq.ft', totalUnits: '120 Flats', baseRate: '₹3200/sq.ft', status: 'NEW LAUNCH', imageUrl: 'url'),
      ];
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoading = false; notifyListeners(); }
  }
}