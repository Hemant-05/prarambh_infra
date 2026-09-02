class ReviewMessageModel {
  final int id;
  final int advisorId;
  final String message;
  final String createdAt;

  ReviewMessageModel({
    required this.id,
    required this.advisorId,
    required this.message,
    required this.createdAt,
  });

  factory ReviewMessageModel.fromJson(Map<String, dynamic> json) {
    return ReviewMessageModel(
      id: json['id'] ?? 0,
      advisorId: json['advisor_id'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
