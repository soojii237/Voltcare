import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/app_colors.dart';

enum AppFontFamily { poppins, inter }

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.family,
    this.color,
    this.size,
    this.letterSpace,
    this.lineHeight,
    this.weight,
    this.textAlign,
    this.maxLines = 1,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.shadows,
    this.overflow,
    this.softWrap = true,
    this.overrideStyle,
  });

  final String text;
  final String? family;
  final Color? color;
  final Color? decorationColor;
  final double? size;
  final double? letterSpace;
  final double? lineHeight;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final List<Shadow>? shadows;
  final TextOverflow? overflow;
  final bool softWrap;
  final TextStyle? overrideStyle;

  @override
  Widget build(BuildContext context) {
    // If override style is provided, use it directly
    if (overrideStyle != null) {
      return Text(
        text,
        maxLines: maxLines,
        textAlign: textAlign ?? TextAlign.start,
        style: overrideStyle,
        softWrap: softWrap,
        overflow: overflow ?? TextOverflow.ellipsis,
      );
    }

    // Determine which font to use
    final bool useInterFont = family == '';

    // Create the text style with all properties
    final TextStyle textStyle = useInterFont
        ? GoogleFonts.inter(
            color: color ?? AppColors.textboldcolor,
            fontSize: size,
            fontWeight: weight,
            fontStyle: fontStyle ?? FontStyle.normal,
            letterSpacing: letterSpace,
            height: lineHeight,
            decoration: decoration,
            decorationColor: decorationColor ?? AppColors.secondaryColor,
            decorationStyle: decorationStyle,
            decorationThickness: decorationThickness,
            shadows: shadows,
          )
        : GoogleFonts.poppins(
            color: color ?? AppColors.textboldcolor,
            fontSize: size,
            fontWeight: weight,
            fontStyle: fontStyle ?? FontStyle.normal,
            letterSpacing: letterSpace,
            height: lineHeight,
            decoration: decoration,
            decorationColor: decorationColor ?? AppColors.secondaryColor,
            decorationStyle: decorationStyle,
            decorationThickness: decorationThickness,
            shadows: shadows,
          );

    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign ?? TextAlign.start,
      style: textStyle,
      softWrap: softWrap,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}