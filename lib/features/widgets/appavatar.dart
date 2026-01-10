import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final String? name;
  final File? file;
  final Color textColor;
  final Color backgroundColor;

  const AppAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.name,
    this.file,
    this.textColor = AppColors.primaryColor,
    this.backgroundColor = const Color(0xFFE6E6E6),
  });

  bool get _hasNetworkImage =>
      (imageUrl != null && imageUrl!.trim().isNotEmpty);

  String _firstLetter() {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // If a local file is set (e.g., picked image), show it
    if (file != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: ClipOval(
          child: Image.file(
            file!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // If network image URL is available, show it
    if (_hasNetworkImage) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
        backgroundColor: backgroundColor,
      );
    }

    // Fallback: show first letter in green color
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        _firstLetter(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: (radius).clamp(10, 24).toDouble() + 2.sp,
        ),
      ),
    );
  }
}
