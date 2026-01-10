// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/helper/helper_pagenavigator.dart';
import 'apptext.dart';

class AppBarMn extends StatelessWidget implements PreferredSizeWidget {
  Widget? title;
  bool? titleonly = true, isback = false;
  String? titlename;
  Widget? leading;
  List<Widget>? actions;
  Color? bgcolor;
  double? height;
  double? toolbarHeight;
  PreferredSizeWidget? bottom;
  AppBarMn(
      {super.key,
      this.titlename,
      this.bgcolor,
      this.title,
      this.titleonly,
      this.toolbarHeight,
      this.leading,
      this.actions,
      this.height,
      this.bottom,
      this.isback});
  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: toolbarHeight,
        shadowColor: AppColors.transparent,
        backgroundColor:bgcolor?? AppColors.primaryColor,

        elevation: 0,
        titleSpacing: 10,
        flexibleSpace: Container(
          decoration: const BoxDecoration(),
        ),
        centerTitle: false,
        title: titleonly == true
            ? AppText(
      text: titlename ?? '',
      size: 18.h,
      letterSpace: 0.4,
      weight: FontWeight.w600,
    )
            : title,
        leading: isback == true
            ? InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        Screen.close(context);
      },
      child: Icon(
        CupertinoIcons.left_chevron,
        // ignore: deprecated_member_use
        color: AppColors.textboldcolor,
      ),
    )
            : leading,
        actions: actions,
        bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 50.h);
}

class ApBarMnHmSc extends StatelessWidget implements PreferredSizeWidget {
  String? title;
  Widget? leading;
  Widget? titlewidget;
  List<Widget>? actions;
  ApBarMnHmSc(
      {super.key, this.title, this.leading, this.actions, this.titlewidget});
  @override
  Widget build(BuildContext context) {
    return AppBar(
       shadowColor: AppColors.transparent,
        titleSpacing: 10,
        elevation: 0,
        title: titlewidget ?? Text(title ?? ''),
        leading: leading,
        actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
