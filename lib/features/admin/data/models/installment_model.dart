class UpcomingInstallmentModel {
  final int dealId;
  final int installmentIndex;
  final String clientName;
  final String clientNumber;
  final String advisorCode;
  final String advisorName;
  final String? projectName;
  final String? unitNumber;
  final String installmentDate;
  final String installmentAmount;
  final String installmentStatus;
  final bool isOverdue;

  UpcomingInstallmentModel({
    required this.dealId,
    required this.installmentIndex,
    required this.clientName,
    required this.clientNumber,
    required this.advisorCode,
    required this.advisorName,
    this.projectName,
    this.unitNumber,
    required this.installmentDate,
    required this.installmentAmount,
    required this.installmentStatus,
    required this.isOverdue,
  });

  factory UpcomingInstallmentModel.fromJson(Map<String, dynamic> json) {
    return UpcomingInstallmentModel(
      dealId: json['deal_id'] ?? 0,
      installmentIndex: json['installment_index'] ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientNumber: json['client_number']?.toString() ?? '',
      advisorCode: json['advisor_code']?.toString() ?? '',
      advisorName: json['advisor_name']?.toString() ?? '',
      projectName: json['project_name']?.toString(),
      unitNumber: json['unit_number']?.toString(),
      installmentDate: json['installment_date']?.toString() ?? '',
      installmentAmount: json['installment_amount']?.toString() ?? '0',
      installmentStatus: json['installment_status']?.toString() ?? 'Pending',
      isOverdue: json['is_overdue'] == true || json['is_overdue'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deal_id': dealId,
      'installment_index': installmentIndex,
      'client_name': clientName,
      'client_number': clientNumber,
      'advisor_code': advisorCode,
      'advisor_name': advisorName,
      'project_name': projectName,
      'unit_number': unitNumber,
      'installment_date': installmentDate,
      'installment_amount': installmentAmount,
      'installment_status': installmentStatus,
      'is_overdue': isOverdue,
    };
  }
}
