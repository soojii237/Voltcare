import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  // Private constructor to prevent instantiation
  CustomSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    String? title,
    bool showCloseIcon = true,
    VoidCallback? onTap,
  }) {
    final config = _getSnackBarConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackBarContent(
          message: message,
          title: title,
          icon: config.icon,
          iconColor: config.iconColor,
          backgroundColor: config.backgroundColor,
          textColor: config.textColor,
          showCloseIcon: showCloseIcon,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        padding: EdgeInsets.zero,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  // Success Snackbar
  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Success',
      type: SnackBarType.success,
      duration: duration,
      showCloseIcon: showCloseIcon,
    );
  }

  // Error Snackbar
  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Error',
      type: SnackBarType.error,
      duration: duration,
      showCloseIcon: showCloseIcon,
    );
  }

  // Warning Snackbar
  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Warning',
      type: SnackBarType.warning,
      duration: duration,
      showCloseIcon: showCloseIcon,
    );
  }

  // Info Snackbar
  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Info',
      type: SnackBarType.info,
      duration: duration,
      showCloseIcon: showCloseIcon,
    );
  }

  static _SnackBarConfig _getSnackBarConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFFD1FAE5),
          textColor: const Color(0xFF065F46),
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: Icons.error,
          iconColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFF991B1B),
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFF92400E),
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: Icons.info,
          iconColor: const Color(0xFF3B82F6),
          backgroundColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF1E40AF),
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;

  _SnackBarConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
  });
}

class _SnackBarContent extends StatelessWidget {
  const _SnackBarContent({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
    this.title,
    this.showCloseIcon = true,
  });

  final String message;
  final String? title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final bool showCloseIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            icon,
            color: iconColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (title != null) SizedBox(height: 2.h),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    color: textColor.withOpacity(0.9),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Close button
          if (showCloseIcon) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Icon(
                Icons.close,
                color: textColor.withOpacity(0.6),
                size: 20.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}