import 'package:flutter/material.dart';
import '../../data/models/sales_analytics_model.dart';
import '../../data/repositories/admin_analytics_repository.dart';

class AdminAnalyticsProvider extends ChangeNotifier {
  final AdminAnalyticsRepository repository;

  AdminAnalyticsProvider({required this.repository});

  SalesAnalyticsModel? _analyticsData;
  bool _isLoading = false;
  String? _errorMessage;

  SalesAnalyticsModel? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSalesAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _analyticsData = await repository.getSalesAnalytics();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
