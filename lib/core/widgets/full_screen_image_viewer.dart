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
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: title != null
            ? Text(
                title!,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
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
                child: _buildImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
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
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image,
          color: Colors.white,
          size: 64,
        ),
      );
    }
  }
}
