import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimensions {
static const double padding = 8;
static const double paddingSmall = padding / 2;
static const double paddingLarge = padding * 2;
static const double paddingXL = padding * 4;
static const double paddingTiny = paddingSmall / 2;
static const double padding26 = 26;
static const double padding20 = 20;
static const double padding17 = 17;
static const double padding18 = 18;


static final gap = SizedBox(height: padding.w);
static final gapXL = SizedBox(height: paddingXL.w);
static final textfieldGap = SizedBox(height: padding26.w);
static final gapLarge = SizedBox(height: paddingLarge.w);
static final gapLarge18 = SizedBox(height: 18.w);
static final gapSmall = SizedBox(height: paddingSmall.w);
static final gap13 = SizedBox(height: 13.h);
static final gap11 = SizedBox(height: 11.h);
static final gap17 = SizedBox(height: 17.h);
static final gap21 = SizedBox(height: 21.h);
static final gap26 = SizedBox(height: 26.h);
static final gap20 = SizedBox(height: 20.h);
static final gap24 = SizedBox(height: 24.h);
static final gap40 = SizedBox(height: 40.h);

static final gapTiny = SizedBox(height: paddingTiny.h);

static final gapHorizontal = SizedBox(width: padding.w);
static final gapHorizontalLarge = SizedBox(width: paddingLarge.w);
static final gapHorizontalXl = SizedBox(width: paddingXL.w);
static final gapHorizontalSmall = SizedBox(width: paddingSmall.w);
static final gapHorizontalTiny = SizedBox(width: paddingTiny.w);
static final gapHorizontal20 = SizedBox(width: padding20);

static final double screenpadding = 24;
static const double screenpaddingmini = 16;

static const Duration animationDuration = Duration(seconds: 1);

}