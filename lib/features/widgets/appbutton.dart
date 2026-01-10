import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/utils/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final bool isActive;
  final bool isLoading;
  final Widget? child;
  final String? text;
  final VoidCallback? onPressed;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    this.isActive = true,
    this.isLoading = false,
    this.child,
    this.text,
    this.onPressed,
    this.activeColor,
    this.inactiveColor,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? (activeColor ?? AppColors.primaryColor)
              : (inactiveColor ?? Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          ),
        ),
        onPressed: (isActive && !isLoading) ? onPressed : null,
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : child ??
                Text(
                  text ?? "Button",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}