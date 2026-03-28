import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/advisor_dashboard_model.dart';

class AdvisorRepository {
  final ApiClient apiClient;
  AdvisorRepository({required this.apiClient});

  Future<AdvisorDashboardModel> getDashboardData(String advisorId) async {
    try {
      // TODO: Replace with actual API call when ready
      // final response = await apiClient.getAdvisorDashboard(advisorId);
      // return AdvisorDashboardModel.fromJson(response['data']);

      // --- MOCK DATA FOR NOW ---
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
      return AdvisorDashboardModel.fromJson({
        "name": "Rajesh Kumar",
        "role": "MANAGER",
        "advisor_id": "#PI-8821",
        "parent_name": "Amit Singh",
        "current_level": "Senior Adviser",
        "next_level": "DIRECTOR",
        "progress_percent": 82,
        "sales": {"suspecting": 102, "prospecting": 25, "site_visit": 10},
        "pending_actions": [
          {"title": "Recruitment Follow-up", "subtitle": "Call for Actions: Team Recruit...", "time": "10:00 AM"},
          {"title": "Upload KYC Documents", "subtitle": "PAN, Aadhaar, Photo, Cancel...", "time": "Due Today"},
          {"title": "Installment Reminder", "subtitle": "Old installments - Call to cust...", "time": "Tomorrow"},
          {"title": "Pending Site Visit", "subtitle": "Site visit today with rajesh kum...", "time": "Due Today"},
        ],
        "promotion_status": [
          {"metric": "Personal Booking", "target": "1", "achieved": "1"},
          {"metric": "Team Booking", "target": "4", "achieved": "3"},
          {"metric": "Team Size", "target": "20", "achieved": "15"},
          {"metric": "Attendance", "target": "10", "achieved": "05"},
        ],
        "active_contests": [
          {"title": "Top 3 Advisor in Recruitment"},
          {"title": "Top 3 Advisor in Site Visit"},
          {"title": "Top 3 Advisor in Booking"},
          {"title": "Goa, Malesiya", "subtitle": "Qualify for: Trip to Goa/Malaysia"},
        ]
      });
    } catch (e) {
      rethrow;
    }
  }
}