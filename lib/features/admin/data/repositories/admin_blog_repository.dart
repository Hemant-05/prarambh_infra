import '../../../../data/datasources/remote/api_client.dart';
import '../../../../features/client/data/models/blog_model.dart';
import 'dart:io';

class AdminBlogRepository {
  final ApiClient _apiClient;

  AdminBlogRepository(this._apiClient);

  Future<List<BlogModel>> getAdminBlogs({String? status}) async {
    final response = await _apiClient.getBlogs(status);
    if (response['status'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => BlogModel.fromJson(json)).toList();
    }
    throw response['message'] ?? 'Failed to fetch blogs';
  }

  Future<bool> createBlog({
    required String title,
    required String content,
    File? image,
  }) async {
    final response = await _apiClient.addBlog(title, content, image);
    return response['status'] == true;
  }

  Future<bool> deleteBlog(String id) async {
    final response = await _apiClient.deleteBlog(id);
    return response['status'] == true;
  }

  Future<bool> updateBlog({
    required String id,
    String? title,
    String? content,
    File? image,
  }) async {
    final response = await _apiClient.updateBlog(id, title, content, image);
    return response['status'] == true;
  }
}
