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
  final double totalGross;
  final double totalEarned;
  final double totalPending;

  IncomeSummary({
    required this.totalGross,
    required this.totalEarned,
    required this.totalPending,
  });

  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    return IncomeSummary(
      totalGross: double.tryParse(json['total_gross'].toString()) ?? 0.0,
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
  final double installmentCommission;
  final int installmentIndex;
  final int totalInstallments;
  final String status;
  final String installmentDate;
  final String projectName;
  final String unitNumber;
  final String? clientName;
  final String formattedDate;
  final double gross;
  final double net;
  final double slab;
  final double emiPercentage;

  IncomeTransaction({
    required this.incomeId,
    required this.dealId,
    required this.totalSqft,
    required this.commissionPerSqft,
    required this.totalCommission,
    required this.installmentCommission,
    required this.installmentIndex,
    required this.totalInstallments,
    required this.status,
    required this.installmentDate,
    required this.projectName,
    required this.unitNumber,
    this.clientName,
    required this.formattedDate,
    required this.gross,
    required this.net,
    required this.slab,
    required this.emiPercentage,
  });

  factory IncomeTransaction.fromJson(Map<String, dynamic> json) {
    return IncomeTransaction(
      incomeId: json['income_id'] ?? 0,
      dealId: json['deal_id'] ?? 0,
      totalSqft: json['total_sqft'] ?? 0,
      commissionPerSqft:
          double.tryParse(json['commission_per_sqft'].toString()) ?? 0.0,
      totalCommission:
          double.tryParse(json['total_commission'].toString()) ?? 0.0,
      installmentCommission:
          double.tryParse(json['installment_commission'].toString()) ?? 0.0,
      installmentIndex: json['installment_index'] ?? 1,
      totalInstallments: json['total_installments'] ?? 1,
      status: json['status'] ?? 'Pending',
      installmentDate: json['installment_date'] ?? '',
      projectName: json['project_name'] ?? 'Unknown Project',
      unitNumber: json['unit_number'] ?? 'N/A',
      clientName: json['client_name'],
      formattedDate: json['formatted_date'] ?? '',
      gross: double.tryParse(json['gross'].toString()) ?? 0.0,
      net: double.tryParse(json['net'].toString()) ?? 0.0,
      slab: double.tryParse(json['slab'].toString()) ?? 0.0,
      emiPercentage: double.tryParse(json['emi_percentage'].toString()) ?? 0.0,
    );
  }
}
