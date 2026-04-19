import '../../features/admin/data/models/lead_models.dart';

class LeadFilterHelper {
  /// Filters a list of LeadModels based on search text and quality filters.
  static List<LeadModel> filterLeads({
    required List<LeadModel> leads,
    String? query,
    String? category, // 'A', 'B', 'C', 'All'
    String? potential, // 'Hot', 'Warm', 'Cold', 'All'
    DateTime? startDate,
    DateTime? endDate,
    String? attempts, // '0', '1', '2', '3', '4', '5', '5+', or 'All'
    bool? isPriority,
  }) {
    return leads.where((lead) {
      // 1. Search Query (Name, Stage, Address)
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = lead.clientName.toLowerCase().contains(q) ||
            lead.stage.toLowerCase().contains(q) ||
            lead.clientAddress.toLowerCase().contains(q);
        if (!matches) return false;
      }

      // 2. Category Filter
      if (category != null && category != 'All' && category.isNotEmpty) {
        if (lead.leadCategory.toLowerCase() != category.toLowerCase()) return false;
      }

      // 3. Potential Filter
      if (potential != null && potential != 'All' && potential.isNotEmpty) {
        if (lead.leadPotential.toLowerCase() != potential.toLowerCase()) return false;
      }

      // 4. Date Range Filter
      if (startDate != null || endDate != null) {
        try {
          final date = DateTime.parse(lead.createdAt);
          if (startDate != null && date.isBefore(startDate)) return false;
          if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) return false;
        } catch (e) {}
      }

      // 5. Communication Attempt Filter
      if (attempts != null && attempts != 'All' && attempts.isNotEmpty) {
        final currentCount = lead.communicationAttempt;
        if (attempts == '5+') {
          if (currentCount < 5) return false;
        } else {
          final target = int.tryParse(attempts);
          if (target != null && currentCount != target) return false;
        }
      }

      // 6. Priority Filter
      if (isPriority == true) {
        if (!lead.isPriority) return false;
      }

      return true;
    }).toList();
  }

  /// Filters a list of Lead Maps (used in Dashboard/Priority sections).
  static List<dynamic> filterLeadMaps({
    required List<dynamic> leads,
    String? query,
    String? category,
    String? potential,
    DateTime? startDate,
    DateTime? endDate,
    String? attempts,
    bool? isPriority,
  }) {
    return leads.where((leadMap) {
      final lead = Map<String, dynamic>.from(leadMap);

      // 1. Search Query
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final name = (lead['client_name'] ?? '').toString().toLowerCase();
        final stage = (lead['stage'] ?? '').toString().toLowerCase();
        final address = (lead['client_address'] ?? '').toString().toLowerCase();

        if (!name.contains(q) && !stage.contains(q) && !address.contains(q)) return false;
      }

      // 2. Category
      if (category != null && category != 'All' && category.isNotEmpty) {
        final cat = (lead['lead_category'] ?? '').toString().toLowerCase();
        if (cat != category.toLowerCase()) return false;
      }

      // 3. Potential
      if (potential != null && potential != 'All' && potential.isNotEmpty) {
        final pot = (lead['lead_potential'] ?? '').toString().toLowerCase();
        if (pot != potential.toLowerCase()) return false;
      }

      // 4. Date Range Filter
      if (startDate != null || endDate != null) {
        try {
          final dateStr = (lead['created_at'] ?? '').toString();
          if (dateStr.isNotEmpty) {
            final date = DateTime.parse(dateStr);
            if (startDate != null && date.isBefore(startDate)) return false;
            if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) return false;
          }
        } catch (e) {}
      }

      // 5. Attempts
      if (attempts != null && attempts != 'All' && attempts.isNotEmpty) {
        final currentCount = int.tryParse((lead['communication_attempt'] ?? '0').toString()) ?? 0;
        if (attempts == '5+') {
          if (currentCount < 5) return false;
        } else {
          final target = int.tryParse(attempts);
          if (target != null && currentCount != target) return false;
        }
      }

      // 6. Priority Filter
      if (isPriority == true) {
        final prio = lead['is_priority'] == 1 ||
            lead['is_priority'] == true ||
            lead['is_priority'] == '1';
        if (!prio) return false;
      }

      return true;
    }).toList();
  }

  static List<String> get attemptOptions => ['All', '0', '1', '2', '3', '4', '5', '5+'];
}
