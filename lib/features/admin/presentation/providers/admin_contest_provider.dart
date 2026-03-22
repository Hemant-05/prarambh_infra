import 'package:flutter/material.dart';
import '../../data/models/contest_model.dart';
import '../../data/repositories/admin_contest_repository.dart';

class AdminContestProvider extends ChangeNotifier {
  final AdminContestRepository repository;
  AdminContestProvider({required this.repository});

  List<ContestModel> _contests = [];
  bool _isLoading = false;

  List<ContestModel> get contests => _contests;
  bool get isLoading => _isLoading;

  Future<void> fetchContests() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contests = await repository.getContests();
    } catch (e) {
      // Mock Data for UI testing matching your screenshot exactly
      _contests = [
        ContestModel(id: '1', title: 'Monsoon Bonanza', status: 'LIVE', rewardText: 'Trip to Goa', targetText: 'Sell 5 Units', dateRange: 'Oct 1 - Oct 31', imageUrl: 'https://via.placeholder.com/150', endDate: 'Oct 31, 2023',
            topPerformers: [
              TopPerformer(id: 'p1', name: 'Rahul Sharma', location: 'MUMBAI WEST', units: '8 Units', initials: 'RS'),
              TopPerformer(id: 'p2', name: 'Amit Kumar', location: 'PUNE CENTRAL', units: '6 Units', initials: 'AK'),
              TopPerformer(id: 'p3', name: 'Sneha Patel', location: 'BANGALORE', units: '5 Units', initials: 'SP'),
            ],
            rules: ['Minimum deal value must be ₹50 Lakhs per unit sold.', 'Booking amount (min 10%) must be received by the developer by Oct 31st.', 'Only direct bookings are eligible.', 'Participants must be active Advisors.']
        ),
        ContestModel(id: '2', title: 'Top Performer', status: 'LIVE', rewardText: 'iPhone 15 Pro', targetText: 'Gen ₹2Cr Revenue', dateRange: 'Oct 15 - Nov 15', imageUrl: 'https://via.placeholder.com/150'),
        ContestModel(id: '3', title: 'Winter Sales Drive', status: 'LIVE', rewardText: '₹50k Cash Bonus', targetText: 'Sell 3 Villas', dateRange: 'Nov 1 - Dec 31', imageUrl: 'https://via.placeholder.com/150'),
        ContestModel(id: '4', title: 'Year End Blast', status: 'UPCOMING', rewardText: 'Car Upgrade', targetText: 'Highest Sales Volume', dateRange: 'Dec 15 - Jan 15', imageUrl: 'https://via.placeholder.com/150'),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNewContest(Map<String, dynamic> data) async {
    _isLoading = true; notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock Network delay
      // await repository.createContest(data);
      _isLoading = false; notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false; notifyListeners();
      return false;
    }
  }
}