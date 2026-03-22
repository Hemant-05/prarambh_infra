import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_advisor_repository.dart';
import '../../data/models/advisor_application_model.dart';

class AdminAdvisorProvider extends ChangeNotifier {
  final AdminAdvisorRepository repository;

  AdminAdvisorProvider({required this.repository});

  List<AdvisorApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AdvisorApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch from API
      _applications = await repository.getApplications();
    } catch (e) {
      _errorMessage = e.toString();
      // FALLBACK MOCK DATA FOR UI TESTING IF API IS NOT READY
      _applications = [
        AdvisorApplicationModel(
            id: '1', name: 'Rajesh Kumar', status: 'Pending', zone: 'North Zone',
            displayId: '#BK-2023-892', appliedDate: 'Oct 24, 2023', phone: '+91 98765 43210',
            email: 'rajesh.realty@example.com', location: 'Sector 45, Gurgaon',
            documents: [
              KycDocument(id: 'd1', name: 'Aadhar_Front.jpg', type: 'JPG', size: '2.4 MB', url: ''),
              KycDocument(id: 'd2', name: 'PAN_Card_Final.pdf', type: 'PDF', size: '1.1 MB', url: ''),
            ]
        ),
        AdvisorApplicationModel(
            id: '2', name: 'Anita Desai', status: 'Docs Review', zone: 'South Zone',
            displayId: '#BK-2023-92', appliedDate: 'Oct 23, 2023', phone: '', email: '', location: '', documents: []
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}