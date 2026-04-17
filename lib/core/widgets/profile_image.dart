import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'full_screen_image_viewer.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double radius;
  final String heroTag;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const ProfileImage({
    super.key,
    required this.imageUrl,
    required this.initials,
    required this.heroTag,
    this.radius = 22,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final bool isLocal = hasImage && !imageUrl!.startsWith('http');
    final primaryBlue = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap ??
          () {
            if (hasImage) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    imageUrl: imageUrl!,
                    heroTag: heroTag,
                    title: 'Profile Image',
                  ),
                ),
              );
            }
          },
      borderRadius: BorderRadius.circular(radius),
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border,
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: hasImage ? Colors.grey[200] : primaryBlue.withOpacity(0.1),
            backgroundImage: hasImage 
                ? (isLocal ? FileImage(File(imageUrl!)) : NetworkImage(imageUrl!)) as ImageProvider
                : null,
            child: !hasImage
                ? Text(
                    initials,
                    style: GoogleFonts.montserrat(
                      fontSize: radius * 0.7,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
