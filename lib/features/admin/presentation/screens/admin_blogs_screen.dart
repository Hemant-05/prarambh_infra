import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_blog_provider.dart';
import 'add_blog_screen.dart';

class AdminBlogsScreen extends StatefulWidget {
  const AdminBlogsScreen({super.key});

  @override
  State<AdminBlogsScreen> createState() => _AdminBlogsScreenState();
}

class _AdminBlogsScreenState extends State<AdminBlogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBlogProvider>().fetchBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

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
          'Blog Management',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBlogScreen()),
        ),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add New Post',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AdminBlogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.blogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No blogs published yet.',
                    style: GoogleFonts.montserrat(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.blogs.length,
            itemBuilder: (context, index) {
              final blog = provider.blogs[index];
              return _buildBlogCard(context, blog, isDark, primaryBlue);
            },
          );
        },
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, dynamic blog, bool isDark, Color primaryBlue) {
    final cardColor = AppColors.getCardColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              blog.fullImageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported_outlined, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: blog.status.toLowerCase() == 'active' 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        blog.status.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: blog.status.toLowerCase() == 'active' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    Text(
                      blog.publishDate,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  blog.title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  blog.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, blog.id.toString()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddBlogScreen(blog: blog),
                          ),
                        ).then((_) {
                           // Refresh if needed, though provider handles it
                           context.read<AdminBlogProvider>().fetchBlogs();
                        });
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                      label: Text('Edit Post', style: GoogleFonts.montserrat(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Blog', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this blog post?', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<AdminBlogProvider>().deleteBlog(id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Blog deleted successfully'), backgroundColor: Colors.green),
                );
              }
            },
            child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
