import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/repositories/admin_project_repository.dart';

class AdminProjectProvider extends ChangeNotifier {
  final AdminProjectRepository repository;
  AdminProjectProvider({required this.repository});

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _searchQuery = '';
  String _filterType = 'All';
  String _filterConstruction = 'All';
  String _filterStatus = 'All';

  List<UnitModel> _inventory = [];
  bool _isLoadingInventory = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterConstruction => _filterConstruction;
  String get filterStatus => _filterStatus;

  List<ProjectModel> get filteredProjects {
    return _projects.where((project) {
      final matchesSearch = project.projectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.developerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.reraNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.city.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _filterType == 'All' || project.projectType == _filterType;
      final matchesConstruction = _filterConstruction == 'All' || project.constructionStatus == _filterConstruction;
      final matchesStatus = _filterStatus == 'All' || project.status == _filterStatus;

      return matchesSearch && matchesType && matchesConstruction && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilters({String? type, String? construction, String? status}) {
    if (type != null) _filterType = type;
    if (construction != null) _filterConstruction = construction;
    if (status != null) _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = 'All';
    _filterConstruction = 'All';
    _filterStatus = 'All';
    notifyListeners();
  }

  List<UnitModel> get inventory => _inventory;
  bool get isLoadingInventory => _isLoadingInventory;

  // --- Inventory Stats ---
  int get totalUnitsCount => _inventory.length;

  int get availableUnitsCount => _inventory
      .where((u) => u.availabilityStatus.toLowerCase() == 'available')
      .length;

  int get bookedUnitsCount => _inventory
      .where((u) => u.availabilityStatus.toLowerCase() == 'booked')
      .length;

  int get soldUnitsCount => _inventory
      .where(
        (u) =>
            u.availabilityStatus.toLowerCase() == 'sold' ||
            u.availabilityStatus.toLowerCase() == 'sold out',
      )
      .length;

  Future<void> fetchProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await repository.getAllProjects();
    } catch (e) {
      debugPrint('Fetch Projects Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProject({
    required String projectName,
    required String developerName,
    required String description,
    required String reraNumber,
    required String projectType,
    required String constructionStatus,
    required String fullAddress,
    required String location,
    required String city,
    required String marketValue,
    required String totalPlots,
    required String buildArea,
    required String ratePerSqft,
    required String budgetRange,
    required String amenities,
    required String specialties,
    File? videoFile,
    File? brochureFile,
    required List<File> projectImages,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.addProject(
        projectName: projectName,
        developerName: developerName,
        description: description,
        reraNumber: reraNumber,
        projectType: projectType,
        constructionStatus: constructionStatus,
        fullAddress: fullAddress,
        location: location,
        city: city,
        marketValue: marketValue,
        totalPlots: totalPlots,
        buildArea: buildArea,
        ratePerSqft: ratePerSqft,
        budgetRange: budgetRange,
        amenities: amenities,
        specialties: specialties,
        videoFile: videoFile,
        brochureFile: brochureFile,
        projectImages: projectImages,
      );
      if (success) await fetchProjects();
      return success;
    } catch (e) {
      debugPrint('Create Project Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> modifyProject({
    required String id,
    String? projectName,
    String? developerName,
    String? description,
    String? projectType,
    String? constructionStatus,
    String? fullAddress,
    String? location,
    String? city,
    String? marketValue,
    String? totalPlots,
    String? buildArea,
    String? ratePerSqft,
    String? specialties,
    String? amenities,
    String? budgetRange,
    String? reraNumber,
    String? status,
    File? videoFile,
    File? brochureFile,
    List<File>? projectImages,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.updateProject(
        id: id,
        projectName: projectName,
        developerName: developerName,
        description: description,
        projectType: projectType,
        constructionStatus: constructionStatus,
        fullAddress: fullAddress,
        location: location,
        city: city,
        marketValue: marketValue,
        totalPlots: totalPlots,
        buildArea: buildArea,
        ratePerSqft: ratePerSqft,
        specialties: specialties,
        amenities: amenities,
        budgetRange: budgetRange,
        reraNumber: reraNumber,
        status: status,
        videoFile: videoFile,
        brochureFile: brochureFile,
        projectImages: projectImages,
      );
      if (success) await fetchProjects();
      return success;
    } catch (e) {
      debugPrint('Update Project Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeProject(String projectId) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.deleteProject(projectId);
      if (success) _projects.removeWhere((p) => p.id.toString() == projectId);
      return success;
    } catch (e) {
      debugPrint('Delete Project Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> fetchInventory(String projectId) async {
    _isLoadingInventory = true;
    notifyListeners();
    try {
      _inventory = await repository.getUnits(projectId: projectId);
    } catch (e) {
      debugPrint('Fetch Inventory Error: $e');
    } finally {
      _isLoadingInventory = false;
      notifyListeners();
    }
  }

  Future<bool> bulkUploadUnits(String projectId, File csvFile) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.bulkUploadUnits(projectId, csvFile);
      if (success) await fetchInventory(projectId);
      return success;
    } catch (e) {
      debugPrint('Bulk Upload Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<UnitModel> getUnitDetails(String unitId) async {
    try {
      return await repository.getUnitDetails(unitId);
    } catch (e) {
      debugPrint('Get Unit Details Error: $e');
      rethrow;
    }
  }

  Future<ProjectModel> getProjectDetails(String projectId) async {
    try {
      return await repository.getProjectDetails(projectId);
    } catch (e) {
      debugPrint('Get Project Details Error: $e');
      rethrow;
    }
  }

  Future<bool> createUnit(
    Map<String, dynamic> data,
    String projectId, {
    List<File>? unitImages,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.addUnit(
        projectId: projectId,
        towerName: data['tower_name']?.toString() ?? '',
        floorNumber: data['floor_number']?.toString() ?? '',
        unitNumber: data['unit_number']?.toString() ?? '',
        configuration: data['configuration']?.toString() ?? '',
        propertyType: data['property_type']?.toString() ?? '',
        saleCategory: data['sale_category']?.toString() ?? '',
        facing: data['facing']?.toString() ?? '',
        location: data['Location']?.toString() ?? '',
        plotNumber: data['plot_number']?.toString() ?? '',
        plotDimensions: data['plot_dimensions']?.toString() ?? '',
        areaSqft: data['area_sqft']?.toString() ?? '',
        ratePerSqft: data['rate_per_sqft']?.toString() ?? '',
        size: data['size']?.toString() ?? '',
        availabilityStatus: data['availability_status']?.toString() ?? '',
        unitImages: unitImages,
      );
      if (success) await fetchInventory(projectId);
      return success;
    } catch (e) {
      debugPrint('Create Unit Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> modifyUnit(
    String unitId,
    Map<String, dynamic> data,
    String projectId, {
    List<File>? unitImages,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.updateUnit(
        unitId: unitId,
        projectId: projectId,
        towerName: data['tower_name']?.toString(),
        floorNumber: data['floor_number']?.toString(),
        unitNumber: data['unit_number']?.toString(),
        configuration: data['configuration']?.toString(),
        propertyType: data['property_type']?.toString(),
        saleCategory: data['sale_category']?.toString(),
        facing: data['facing']?.toString(),
        location: data['Location']?.toString(),
        plotNumber: data['plot_number']?.toString(),
        plotDimensions: data['plot_dimensions']?.toString(),
        areaSqft: data['area_sqft']?.toString(),
        ratePerSqft: data['rate_per_sqft']?.toString(),
        size: data['size']?.toString(),
        availabilityStatus: data['availability_status']?.toString(),
        unitImages: unitImages,
      );
      if (success) await fetchInventory(projectId);
      return success;
    } catch (e) {
      debugPrint('Update Unit Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeUnit(String unitId, String projectId) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.deleteUnit(unitId);
      if (success) _inventory.removeWhere((u) => u.id.toString() == unitId);
      return success;
    } catch (e) {
      debugPrint('Delete Unit Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
