import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/features/widgets/appsvg.dart';

import '../../model/idvalue_model.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimensions.dart';
import '../../utils/extension/space_ext.dart';
import 'apptext.dart';

class AppDropdownWithEmptyState extends StatelessWidget {
  const AppDropdownWithEmptyState({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    required this.iconAsset,
    this.value,
    this.isLoading = false,
    this.emptyMessage,
    this.height,
    this.width,
    this.style = DropdownStyle.idValue, // Default to IdValue style
  });

  final List<dynamic> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final String iconAsset;
  final dynamic value;
  final bool isLoading;
  final String? emptyMessage;
  final double? height;
  final double? width;
  final DropdownStyle style;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = items.isEmpty;
    String defaultEmptyMessage = emptyMessage ?? _getDefaultEmptyMessage(hintText);

    return Container(
      height: height ?? 40.h,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(8.7.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: DropdownButtonHideUnderline(
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                ),
              )
            : DropdownButton<String>(
                value: _getCurrentValue() != null && _isValueInItems(_getCurrentValue()!) ? _getCurrentValue() : null,
                isExpanded: true,
                icon: Icon(
                  CupertinoIcons.chevron_down,
                  color: AppColors.textlightcolor,
                  size: 20.h,
                ),
                hint: Row(
                  children: [
                    AppSvg(assetName: iconAsset),
                    AppDimensions.gapHorizontalSmall,
                    AppText(
                      text: hintText,
                      size: 14.h,
                      weight: FontWeight.w400,
                      color: AppColors.textlightcolor,
                    ),
                  ],
                ),
                items: isEmpty ? [
                  // Show empty state message as a dropdown item when clicked
                  DropdownMenuItem<String>(
                    value: null,
                    enabled: false, // Make it non-selectable
                    child: Row(
                      children: [
                        AppSvg(assetName: iconAsset),
                        AppDimensions.gapHorizontalSmall,
                        Flexible(
                          child: AppText(
                            text: defaultEmptyMessage,
                            size: 14.h,
                            weight: FontWeight.w400,
                            family: '',
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] : _buildDropdownItems(),
                onChanged: onChanged,
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                style: TextStyle(
                  color: AppColors.textboldcolor,
                  fontSize: 14.h,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ),
    );
  }

  String? _getCurrentValue() {
    if (value == null) return null;
    
    switch (style) {
      case DropdownStyle.idValue:
        return (value as IdValue?)?.value;
      case DropdownStyle.string:
        return value as String?;
      case DropdownStyle.dynamic:
        // For dynamic objects, try to extract a value
        if (value is Map) {
          return value['id']?.toString() ?? value['value']?.toString();
        }
        // For typed objects, try to access id property directly
        try {
          return value.id?.toString() ?? '';
        } catch (e) {
          // If reflection fails, fall back to toString
        }
        return value?.toString();
    }
  }

  String _getItemValue(dynamic item) {
    switch (style) {
      case DropdownStyle.idValue:
        return (item as IdValue).value ?? '';
      case DropdownStyle.string:
        return item as String;
      case DropdownStyle.dynamic:
        // For dynamic objects, try to extract a value for selection
        if (item is Map) {
          return item['id']?.toString() ?? item['value']?.toString() ?? '';
        }
        // For typed objects, try to access id property directly
        try {
          // Try to access id property using reflection-like approach
          return item.id?.toString() ?? '';
        } catch (e) {
          // If reflection fails, fall back to toString
        }
        return item?.toString() ?? '';
    }
  }

  String _getItemText(dynamic item) {
    switch (style) {
      case DropdownStyle.idValue:
        return (item as IdValue).value ?? '';
      case DropdownStyle.string:
        return item as String;
      case DropdownStyle.dynamic:
        // For dynamic objects, try to extract display text based on object type
        if (item is Map) {
          // Try common property names
          return item['name']?.toString() ?? 
                 item['value']?.toString() ?? 
                 item['text']?.toString() ??
                 item['courseCode']?.toString() ??
                 item['title']?.toString() ?? '';
        }
        // For typed objects, try to access properties directly
        try {
          // Try to access name property using reflection-like approach
          if (item.runtimeType.toString().contains('Course')) {
            // For course objects, try to get name or courseCode
            return (item.name?.toString() ?? item.courseCode?.toString()) ?? '';
          } else if (item.runtimeType.toString().contains('Module')) {
            // For module objects, try to get name
            return item.name?.toString() ?? '';
          } else if (item.runtimeType.toString().contains('Batch')) {
            // For batch objects, try to get name
            return item.name?.toString() ?? '';
          }
        } catch (e) {
          // If reflection fails, fall back to toString
        }
        return item?.toString() ?? '';
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    Set<String> usedValues = {}; // Track used values to prevent duplicates
    
    for (final item in items) {
      String itemValue = _getItemValue(item);
      
      // Skip items with duplicate values or empty values
      if (usedValues.contains(itemValue) || itemValue.isEmpty) {
        continue;
      }
      usedValues.add(itemValue);
      
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: itemValue,
          child: Row(
            children: [
              AppSvg(assetName: iconAsset),
              AppDimensions.gapHorizontalSmall,
              Expanded(
                child: AppText(
                  text: _getItemText(item),
                  size: 14.h,
                  weight: FontWeight.w400,
                  family: '',
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return dropdownItems;
  }

  bool _isValueInItems(String value) {
    for (final item in items) {
      if (_getItemValue(item) == value) {
        return true;
      }
    }
    return false;
  }

  String _getDefaultEmptyMessage(String hintText) {
    // Generate appropriate empty message based on hint text
    String lowerHint = hintText.toLowerCase();
    
    if (lowerHint.contains('course')) {
      return 'No course found';
    } else if (lowerHint.contains('module')) {
      return 'No module found';
    } else if (lowerHint.contains('batch')) {
      return 'No batch found';
    } else if (lowerHint.contains('student')) {
      return 'No student found';
    } else if (lowerHint.contains('subject')) {
      return 'No subject found';
    } else if (lowerHint.contains('exam')) {
      return 'No exam found';
    } else if (lowerHint.contains('class')) {
      return 'No class found';
    } else if (lowerHint.contains('department')) {
      return 'No department found';
    } else {
      return 'No data found';
    }
  }
}

enum DropdownStyle {
  idValue,    // For IdValue objects
  string,     // For simple string lists
  dynamic,    // For dynamic objects (Maps, etc.)
}

// Legacy dropdown for backward compatibility with existing MyAppDropDown
class MyAppDropDownWithEmptyState extends StatelessWidget {
  const MyAppDropDownWithEmptyState({
    super.key,
    required this.onChange,
    required this.items,
    this.value,
    this.hint,
    this.focusnode,
    this.height,
    this.width,
    this.label,
    this.emptyMessage,
  });

  final Function(String?) onChange;
  final List<String> items;
  final String? value, hint, label, emptyMessage;
  final FocusNode? focusnode;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = items.isEmpty;
    String defaultEmptyMessage = emptyMessage ?? 'No data found';

    return SizedBox(
      width: width ?? ScreenUtil().screenWidth,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            AppText(
              text: label!,
              size: 12.h,
              weight: FontWeight.w500,
              color: AppColors.textboldcolor,
            ),
            4.0.hBox,
          ],
          Container(
            height: height ?? 20.3.h,
            child: Center(
              child: DropdownButton<String>(
                icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 16),
                dropdownColor: AppColors.white,
                padding: EdgeInsets.zero,
                isDense: true,
                isExpanded: true,
                value: value,
                focusNode: focusnode,
                autofocus: true,
                style: TextStyle(
                  fontSize: 10.h,
                  fontWeight: FontWeight.w500,
                ),
                hint: AppText(
                  text: hint ?? 'Select',
                  weight: FontWeight.w400,
                  size: 10,
                  family: '',
                ),
                underline: Container(),
                items: isEmpty ? [
                  DropdownMenuItem<String>(
                    value: null,
                    enabled: false,
                    child: AppText(
                      text: defaultEmptyMessage,
                      weight: FontWeight.w400,
                      size: 10.h,
                      color: AppColors.error,
                    ),
                  ),
                ] : items.map((list) {
                  return DropdownMenuItem<String>(
                    value: list,
                    child: AppText(
                      text: list,
                      weight: FontWeight.w500,
                      size: 10.h,
                    ),
                  );
                }).toList(),
                onChanged: onChange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
