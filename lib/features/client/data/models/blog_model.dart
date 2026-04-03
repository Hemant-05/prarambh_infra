// lib/features/client/data/models/blog_model.dart

class BlogModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final String publishDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  BlogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.publishDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      publishDate: json['publish_date'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'publish_date': publishDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullImageUrl {
    if (image.isEmpty) return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=800';
    if (image.startsWith('http')) return image;
    return 'https://workiees.com/$image';
  }
}
