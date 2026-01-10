import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';

showAppDatePicker(BuildContext context,
    {DateTime? selectedDate,
    bool isAllowPastDate = false,
    bool isAllowFutureDate = true}) async {
  selectedDate ??= DateTime.now();

  final DateTime? picked = await showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.white, // header background color
              onPrimary: AppColors.textboldcolor, // header text color
              onSurface: AppColors.textboldcolor, // body text color (date text)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textboldcolor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedDate,
      firstDate:
          isAllowPastDate ? DateTime(DateTime.now().year - 50) : DateTime.now(),
      lastDate: isAllowFutureDate
          ? DateTime(DateTime.now().year + 1)
          : DateTime.now());

  if (picked != null && picked != selectedDate) {
    selectedDate = picked;
  }
  debugPrint("$selectedDate");
  return DateFormat('yyyy-MM-dd').format(selectedDate).toString();
}

// string date convert to date
converttdatetostring(String date) {
  return DateFormat('yyyy-MM-dd').format(DateTime.parse(date)).toString();
}

// covert date string to date and time
converttdatetostringwithtime(String date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss')
      .format(DateTime.parse(date))
      .toString();
}

// convert date string to with day name
converttdatetoincday(String date) {
  try {
    return DateFormat('dd EEEE yyyy').format(DateTime.parse(date)).toString();
  } catch (e) {
    return DateFormat('dd EEEE yyyy').format(DateTime.now()).toString();
  }
  
}
// convert date string like 23 Apr
converttdatetodaymonth(String date) {
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date)).toString();
  } catch (e) {
    return DateFormat('dd EEEE yyyy').format(DateTime.now()).toString();
  }
  
}

// convert date string to with day name like Thursday 12
converttdatetoincdayandname(String date) {
  try {
    return DateFormat('EEEE dd').format(DateTime.parse(date)).toString();
  } catch (e) {
    return DateFormat('EEEE dd').format(DateTime.now()).toString();
  }
  
}
// convert date string to with day name like Aug 13 2025
converttdatetoincdayandnameyear(String date) {
    try {
    return DateFormat('MMM dd yyyy').format(DateTime.parse(date));
  } catch (e) {
    return DateFormat('MMM dd yyyyy').format(DateTime.now());
  }
  
}
// convert date string to with month name like April 12
String convertDateToMonthAndDay(String date) {
  try {
    return DateFormat('MMM dd').format(DateTime.parse(date));
  } catch (e) {
    return DateFormat('MMM dd').format(DateTime.now());
  }
}

// check years difference is a 1 year
bool isDifferenceExactlyOneYear(String startDateStr, String endDateStr) {
  // Parse the date strings into DateTime objects
  DateTime startDate = DateTime.parse(startDateStr);
  DateTime endDate = DateTime.parse(endDateStr);

  // Calculate the difference in years
  int yearDifference = endDate.year - startDate.year;

  return yearDifference == 1 &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day;
}

int differenceInDaysFromToday(DateTime startdate,DateTime enddate) {
  try {
    DateTime parsedDate = enddate;
    DateTime today = startdate;
    log('${parsedDate.difference(today).inDays}');
    return parsedDate.difference(today).inDays;
  } catch (e) {
    debugPrint("Error parsing date: $e");
    return 0;
  }
}

// convert time of day to string like 12:00 AM
String convertTimeOfDayToString(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat.jm().format(dt); 
}
//  return value ike 12 AM
String convertTimeOfDayToHourString(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour);
  return DateFormat('h a').format(dt); // 'h a' => 12 AM, 1 PM, etc.
}
//  return value ike 12:00
String convertTimeOfDayToStringwithoutsuff(TimeOfDay time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute'; // e.g., "12:00", "3:30"
}