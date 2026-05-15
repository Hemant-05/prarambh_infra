import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final String? title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.4),
            child: IconButton(
              icon: Icon(Icons.close, color: iconColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: title != null
            ? Text(
                title!,
                style: GoogleFonts.montserrat(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Hero(
              tag: heroTag ?? imageUrl,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: _buildImage(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final loadingColor = isDark ? Colors.white : Colors.black;

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: loadingColor,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: loadingColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(color: loadingColor),
            ),
          ],
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image,
          color: loadingColor,
          size: 64,
        ),
      );
    }
  }
}
