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

    final Map<String, Set<int>> projectDeals = {};
    final Map<String, double> projectCommission = {};

    for (var tx in _incomeData!.transactions) {
      projectDeals.putIfAbsent(tx.projectName, () => <int>{}).add(tx.dealId);
      projectCommission[tx.projectName] = (projectCommission[tx.projectName] ?? 0) + tx.installmentCommission;
    }

    return projectDeals.keys.map((projectName) {
      return ProjectIncomeSummary(
        projectName: projectName,
        units: projectDeals[projectName]!.length,
        totalCommission: projectCommission[projectName]!,
      );
    }).toList();
  }

  List<IncomeTransaction> get paidTransactions {
    return _incomeData?.transactions.where((tx) => tx.status.toLowerCase() == 'paid').toList() ?? [];
  }

  List<IncomeTransaction> get pendingTransactions {
    return _incomeData?.transactions.where((tx) => tx.status.toLowerCase().contains('pending')).toList() ?? [];
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
