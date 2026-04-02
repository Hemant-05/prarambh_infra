import 'package:flutter/material.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import '../../data/repositories/client_property_repository.dart';

class ClientDashboardProvider extends ChangeNotifier {
  final ClientPropertyRepository repository;

  ClientDashboardProvider({required this.repository});

  List<ProjectModel> _projects = [];
  List<UnitModel> _units = [];
  bool _isLoading = false;
  String? _error;

  // Search & History
  List<String> _recentSearches = ['Serenity Heights', 'Willow Haven', 'Azure Skyline'];
  List<ProjectModel> _recentViews = [];

  List<ProjectModel> get projects => _projects;
  List<UnitModel> get units => _units;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get recentSearches => _recentSearches;
  List<ProjectModel> get recentViews => _recentViews;

  // Dashboard selections
  String _selectedCategory = 'Recommended';
  final List<String> _categories = ['Recommended', 'Top Rates', 'Best Offers', 'Most Relevant'];

  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addToRecentViews(ProjectModel project) {
    if (!_recentViews.any((p) => p.id == project.id)) {
      _recentViews.insert(0, project);
      if (_recentViews.length > 10) _recentViews.removeLast();
      notifyListeners();
    }
  }

  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) _recentSearches.removeLast();
    notifyListeners();
  }

  void removeSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projectsFuture = repository.getAllProjects();
      final unitsFuture = repository.getAllUnits();

      final results = await Future.wait([projectsFuture, unitsFuture]);
      _projects = results[0] as List<ProjectModel>;
      _units = results[1] as List<UnitModel>;
      
      // Default recent views if empty for demo
      if (_recentViews.isEmpty && _projects.isNotEmpty) {
        _recentViews = _projects.take(4).toList();
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
