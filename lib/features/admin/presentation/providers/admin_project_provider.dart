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
  bool _isSaving = false; // Used for Add/Update/Delete actions

  List<UnitModel> _inventory = [];
  bool _isLoadingInventory = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  List<UnitModel> get inventory => _inventory;
  bool get isLoadingInventory => _isLoadingInventory;

  // ==========================================
  // PROJECT METHODS
  // ==========================================

  Future<void> fetchProjects() async {
    _isLoading = true; notifyListeners();
    try {
      _projects = await repository.getAllProjects();
    } catch (e) {
      debugPrint('Fetch Projects Error: $e');
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> createProject({
    required String projectName, required String developerName, required String city,
    required String fullAddress, required String status, required String projectType,
    required String constructionStatus, required String marketValue, required String totalPlots,
    required String buildArea, required String reraNumber, required String location,
    required String ratePerSqft, required String budgetRange, required String description,
    required String reraApproved, required String amenities, required String specialties,
    File? video, File? brochure, required List<File> images,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addProject(
        projectName: projectName, developerName: developerName, city: city, fullAddress: fullAddress,
        status: status, projectType: projectType, constructionStatus: constructionStatus,
        marketValue: marketValue, totalPlots: totalPlots, buildArea: buildArea, reraNumber: reraNumber,
        location: location, ratePerSqft: ratePerSqft, budgetRange: budgetRange, description: description,
        reraApproved: reraApproved, amenities: amenities, specialties: specialties,
        video: video, brochure: brochure, images: images,
      );
      if (success) await fetchProjects();
      return success;
    } catch (e) {
      debugPrint('Create Project Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> modifyProject(Map<String, dynamic> data) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateProject(data);
      if (success) await fetchProjects(); // Refresh list
      return success;
    } catch (e) {
      debugPrint('Update Project Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> removeProject(int projectId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.deleteProject(projectId);
      if (success) {
        _projects.removeWhere((p) => p.id == projectId);
      }
      return success;
    } catch (e) {
      debugPrint('Delete Project Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  // ==========================================
  // UNIT / INVENTORY METHODS
  // ==========================================

  Future<void> fetchInventory(int projectId) async {
    _isLoadingInventory = true; notifyListeners();
    try {
      _inventory = await repository.getUnits(projectId);
    } catch (e) {
      debugPrint('Fetch Inventory Error: $e');
    } finally {
      _isLoadingInventory = false; notifyListeners();
    }
  }
  
  Future<bool> createBulkUnits(List<Map<String, dynamic>> unitsData, int projectId) async {
    _isSaving = true;
    notifyListeners();

    int successCount = 0;
    try {
      // Loop through the parsed Excel data and fire the addUnit API for each
      // Using Future.wait to run them concurrently for speed
      await Future.wait(unitsData.map((unitData) async {
        try {
          final success = await repository.addUnit(unitData);
          if (success) successCount++;
        } catch (e) {
          debugPrint('Failed to add unit ${unitData['unit_number']}: $e');
        }
      }));

      // Refresh inventory if at least one unit succeeded
      if (successCount > 0) {
        await fetchInventory(projectId);
      }

      return successCount == unitsData.length; // Returns true if ALL succeeded
    } catch (e) {
      debugPrint('Bulk Upload Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> createUnit(Map<String, dynamic> data, int projectId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addUnit(data);
      if (success) await fetchInventory(projectId); // Refresh inventory
      return success;
    } catch (e) {
      debugPrint('Create Unit Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> modifyUnit(Map<String, dynamic> data, int projectId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateUnit(data);
      if (success) await fetchInventory(projectId); // Refresh inventory
      return success;
    } catch (e) {
      debugPrint('Update Unit Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> removeUnit(int unitId, int projectId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.deleteUnit(unitId);
      if (success) {
        _inventory.removeWhere((u) => u.id == unitId);
      }
      return success;
    } catch (e) {
      debugPrint('Delete Unit Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}