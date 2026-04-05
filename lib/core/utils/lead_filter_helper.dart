import '../../features/admin/data/models/lead_models.dart';
import 'package:intl/intl.dart';

class LeadFilterHelper {
  /// Filters a list of LeadModels based on search text and quality filters.
  static List<LeadModel> filterLeads({
    required List<LeadModel> leads,
    String? query,
    String? category, // 'A', 'B', 'C', 'All'
    String? potential, // 'Hot', 'Warm', 'Cold', 'All'
    String? month, // 'Jan', 'Feb', etc., or 'All'
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

      // 4. Month Filter
      if (month != null && month != 'All' && month.isNotEmpty) {
        try {
          // lead.createdAt is usually 'YYYY-MM-DD'
          final date = DateTime.parse(lead.createdAt);
          final leadMonth = DateFormat('MMM').format(date);
          if (leadMonth != month) return false;
        } catch (e) {
          // If date parsing fails, we skip month filtering for this lead
        }
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
    String? month,
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

      // 4. Month
      if (month != null && month != 'All' && month.isNotEmpty) {
        try {
          final dateStr = (lead['created_at'] ?? '').toString();
          if (dateStr.isNotEmpty) {
            final date = DateTime.parse(dateStr);
            final leadMonth = DateFormat('MMM').format(date);
            if (leadMonth != month) return false;
          }
        } catch (e) {}
      }

      return true;
    }).toList();
  }
  
  static List<String> get months => [
    'All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}
