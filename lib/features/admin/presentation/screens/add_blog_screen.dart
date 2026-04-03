import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/client/data/models/blog_model.dart';
import '../providers/admin_blog_provider.dart';

class AddBlogScreen extends StatefulWidget {
  final BlogModel? blog;
  const AddBlogScreen({super.key, this.blog});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.blog != null) {
      _titleController.text = widget.blog!.title;
      _descriptionController.text = widget.blog!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      bool success = false;
      if (widget.blog != null) {
        // Edit Mode
        success = await context.read<AdminBlogProvider>().updateBlog(
              id: widget.blog!.id.toString(),
              title: _titleController.text,
              content: _descriptionController.text,
              image: _selectedImage,
            );
      } else {
        // Add Mode
        success = await context.read<AdminBlogProvider>().addBlog(
              title: _titleController.text,
              content: _descriptionController.text,
              image: _selectedImage,
            );
      }
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.blog != null ? 'Blog updated successfully' : 'Blog added successfully'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AdminBlogProvider>().error ?? 'Operation failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final provider = context.watch<AdminBlogProvider>();
    final isEdit = widget.blog != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Update Post' : 'Create New Post',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Blog Cover Image', isDark),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : (isEdit && widget.blog!.image.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Image.network(widget.blog!.fullImageUrl, fit: BoxFit.cover, width: double.infinity, height: 200),
                                  Container(color: Colors.black26),
                                  const Center(child: Icon(Icons.edit_outlined, color: Colors.white, size: 40)),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 48, color: primaryBlue),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to upload cover image',
                                  style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 32),
              _buildLabel('Post Title', isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hint: 'Enter a catchy title...',
                isDark: isDark,
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              _buildLabel('Post Description', isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Write your blog description here...',
                isDark: isDark,
                icon: Icons.article_outlined,
                maxLines: 10,
                validator: (v) => v!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Update Post' : 'Publish Post',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.montserrat(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: AppColors.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }
}
