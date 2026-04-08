import 'package:flutter/material.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import '../../data/repositories/advisor_project_repository.dart';

class AdvisorProjectProvider extends ChangeNotifier {
  final AdvisorProjectRepository repository;

  AdvisorProjectProvider({required this.repository});

  List<ProjectModel> _projects = [];
  bool _isLoadingProjects = false;
  String _searchQuery = '';
  String _filterType = 'All';
  String _filterConstruction = 'All';
  String _filterStatus = 'All';

  List<UnitModel> _units = [];
  bool _isLoadingUnits = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoadingProjects => _isLoadingProjects;

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

  List<UnitModel> get units => _units;
  bool get isLoadingUnits => _isLoadingUnits;

  Future<void> fetchProjects() async {
    _isLoadingProjects = true;
    notifyListeners();
    try {
      _projects = await repository.getProjects();
    } catch (e) {
      debugPrint('Fetch Advisor Projects Error: $e');
      _projects = [];
    } finally {
      _isLoadingProjects = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnitsForProject(String projectId) async {
    _isLoadingUnits = true;
    // Clear previous units before loading new ones
    _units = [];
    notifyListeners();
    try {
      _units = await repository.getUnits(projectId);
    } catch (e) {
      debugPrint('Fetch Project Units Error: $e');
      _units = [];
    } finally {
      _isLoadingUnits = false;
      notifyListeners();
    }
  }
}