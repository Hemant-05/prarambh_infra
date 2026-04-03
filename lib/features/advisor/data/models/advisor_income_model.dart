class AdvisorIncomeModel {
  final IncomeSummary summary;
  final List<IncomeTransaction> transactions;

  AdvisorIncomeModel({
    required this.summary,
    required this.transactions,
  });

  factory AdvisorIncomeModel.fromJson(Map<String, dynamic> json) {
    final summaryData = json['summary'] ?? {};
    final List transactionsList = json['transactions'] ?? [];

    return AdvisorIncomeModel(
      summary: IncomeSummary.fromJson(summaryData),
      transactions: transactionsList
          .map((e) => IncomeTransaction.fromJson(e))
          .toList(),
    );
  }
}

class IncomeSummary {
  final double totalEarned;
  final double totalPending;

  IncomeSummary({
    required this.totalEarned,
    required this.totalPending,
  });

  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    return IncomeSummary(
      totalEarned: double.tryParse(json['total_earned'].toString()) ?? 0.0,
      totalPending: double.tryParse(json['total_pending'].toString()) ?? 0.0,
    );
  }
}

class IncomeTransaction {
  final int incomeId;
  final int dealId;
  final int totalSqft;
  final double commissionPerSqft;
  final double totalCommission;
  final String status;
  final String createdAt;
  final String projectName;
  final String unitNumber;
  final String clientName;
  final String clientNumber;
  final String formattedDate;

  IncomeTransaction({
    required this.incomeId,
    required this.dealId,
    required this.totalSqft,
    required this.commissionPerSqft,
    required this.totalCommission,
    required this.status,
    required this.createdAt,
    required this.projectName,
    required this.unitNumber,
    required this.clientName,
    required this.clientNumber,
    required this.formattedDate,
  });

  factory IncomeTransaction.fromJson(Map<String, dynamic> json) {
    return IncomeTransaction(
      incomeId: json['income_id'] ?? 0,
      dealId: json['deal_id'] ?? 0,
      totalSqft: json['total_sqft'] ?? 0,
      commissionPerSqft: double.tryParse(json['commission_per_sqft'].toString()) ?? 0.0,
      totalCommission: double.tryParse(json['total_commission'].toString()) ?? 0.0,
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'] ?? '',
      projectName: json['project_name'] ?? 'Unknown Project',
      unitNumber: json['unit_number'] ?? 'N/A',
      clientName: json['client_name'] ?? 'Unknown Client',
      clientNumber: json['client_number'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
    );
  }
}
