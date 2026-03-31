import 'package:flutter/material.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import '../../data/repositories/advisor_project_repository.dart';

class AdvisorProjectProvider extends ChangeNotifier {
  final AdvisorProjectRepository repository;

  AdvisorProjectProvider({required this.repository});

  List<ProjectModel> _projects = [];
  bool _isLoadingProjects = false;

  List<UnitModel> _units = [];
  bool _isLoadingUnits = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoadingProjects => _isLoadingProjects;

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