// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'app_dropdown_with_empty_state.dart';
class MyAppDropDown extends StatelessWidget {
  MyAppDropDown(
      {super.key,
      required this.onChange,
      required this.items,
      this.value,
      this.hint,
      this.focusnode,
      this.height,
      this.width,
      this.label});
  Function(String?) onChange;
  List<String> items;
  String? value, hint, label;
  FocusNode? focusnode;
  double? width, height;
  @override
  Widget build(BuildContext context) {
    return MyAppDropDownWithEmptyState(
      onChange: onChange,
      items: items,
      value: value,
      hint: hint,
      focusnode: focusnode,
      height: height,
      width: width,
      label: label,
    );
  }
}