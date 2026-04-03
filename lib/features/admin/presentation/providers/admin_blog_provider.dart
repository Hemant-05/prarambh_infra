import 'package:flutter/material.dart';
import '../../../../features/client/data/models/blog_model.dart';
import '../../data/repositories/admin_blog_repository.dart';
import 'dart:io';

class AdminBlogProvider extends ChangeNotifier {
  final AdminBlogRepository _repository;

  AdminBlogProvider(this._repository);

  List<BlogModel> _blogs = [];
  bool _isLoading = false;
  String? _error;

  List<BlogModel> get blogs => _blogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBlogs({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _blogs = await _repository.getAdminBlogs(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBlog({
    required String title,
    required String content,
    File? image,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.createBlog(
        title: title,
        content: content,
        image: image,
      );
      if (success) {
        await fetchBlogs();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBlog(String id) async {
    try {
      final success = await _repository.deleteBlog(id);
      if (success) {
         _blogs.removeWhere((b) => b.id.toString() == id);
         notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBlog({
    required String id,
    String? title,
    String? content,
    File? image,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.updateBlog(
        id: id,
        title: title,
        content: content,
        image: image,
      );
      if (success) {
        await fetchBlogs();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
