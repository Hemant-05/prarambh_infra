import 'package:flutter/material.dart';
import '../../data/models/advisor_income_model.dart';
import '../../data/repositories/advisor_income_repository.dart';

class AdvisorIncomeProvider extends ChangeNotifier {
  final AdvisorIncomeRepository repository;

  AdvisorIncomeProvider({required this.repository});

  AdvisorIncomeModel? _incomeData;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPeriod = 'Monthly'; // Weekly, Monthly, Quarterly, Yearly

  AdvisorIncomeModel? get incomeData => _incomeData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    // In a real application, you might trigger a re-fetch with period parameters
  }

  Future<void> fetchAdvisorIncome(String advisorCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _incomeData = await repository.getAdvisorIncome(advisorCode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Grouped data for "Earnings by Project" table
  List<ProjectIncomeSummary> get earningsByProject {
    if (_incomeData == null) return [];

    final Map<String, ProjectIncomeSummary> projectMap = {};

    for (var tx in _incomeData!.transactions) {
      if (projectMap.containsKey(tx.projectName)) {
        projectMap[tx.projectName] = ProjectIncomeSummary(
          projectName: tx.projectName,
          units: projectMap[tx.projectName]!.units + 1,
          totalCommission: projectMap[tx.projectName]!.totalCommission + tx.totalCommission,
        );
      } else {
        projectMap[tx.projectName] = ProjectIncomeSummary(
          projectName: tx.projectName,
          units: 1,
          totalCommission: tx.totalCommission,
        );
      }
    }

    return projectMap.values.toList();
  }
}

class ProjectIncomeSummary {
  final String projectName;
  final int units;
  final double totalCommission;

  ProjectIncomeSummary({
    required this.projectName,
    required this.units,
    required this.totalCommission,
  });
}
