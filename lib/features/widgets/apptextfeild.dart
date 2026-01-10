import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.isObscure = false,
    this.keyboardType,
    this.textInputAction,
    this.height,
    this.width,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.validator,
    this.textAlign = TextAlign.start,
    this.borderStyle,
    this.errorBorder,
    this.fillColor,
    this.hintStyle,
    this.textStyle,
    this.labelStyle,
    this.errorStyle,
    this.contentPadding,
    this.maxLength,
    this.maxLines = 1,
    this.digitsOnly = false,
    this.focusNode,
    this.showLabelOutside = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool isObscure;
  final bool readOnly;
  final bool enabled;
  final bool digitsOnly;
  final bool showLabelOutside;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? height;
  final double? width;
  final int maxLines;
  final int? maxLength;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? borderStyle;
  final InputBorder? errorBorder;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textField = SizedBox(
      height: height,
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        readOnly: readOnly,
        enabled: enabled,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType ?? TextInputType.text,
        textInputAction: textInputAction,
        textAlign: textAlign,
        textAlignVertical: TextAlignVertical.center,
        focusNode: focusNode,
        onTap: onTap,
        onChanged: onChanged,
        validator: validator,
        enableSuggestions: false,
        scribbleEnabled: false,
        style: textStyle ??
            GoogleFonts.inter(
              color: AppColors.black,
              fontWeight: FontWeight.w300,
              fontSize: 15.sp,
            ),
        inputFormatters: inputFormatters ??
            (digitsOnly
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))]
                : null),
        decoration: InputDecoration(
          labelText: showLabelOutside ? null : label,
          labelStyle: labelStyle ??
              GoogleFonts.poppins(
                color: AppColors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
          hintText: hintText,
          hintStyle: hintStyle ??
              GoogleFonts.inter(
                color: AppColors.textlightcolor,
                fontWeight: FontWeight.w400,
                fontSize: 15.sp,
              ),
          errorStyle: errorStyle,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 18.w),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(),
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
          filled: fillColor != null,
          fillColor: fillColor,
          isDense: true,
          alignLabelWithHint: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: borderStyle ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
          enabledBorder: borderStyle ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
          focusedBorder: borderStyle ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Colors.lightBlue,
                  width: 2,
                ),
              ),
          errorBorder: errorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
          focusedErrorBorder: errorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
          counterText: maxLength != null ? null : '',
        ),
      ),
    );

    // If label should be outside, wrap with Column
    if (showLabelOutside && label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label!,
            style: labelStyle ??
                TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
          ),
          SizedBox(height: 6.h),
          textField,
        ],
      );
    }

    return textField;
  }
}