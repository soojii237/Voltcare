// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../devidedetails/view/daily_graph.dart';
import '../devidedetails/view/weekly_graph.dart';
import '../devidedetails/view/monthly_graph.dart'; // Add this import
import '../../../../utils/dynamic/appvariables.dart';

class UsagePage extends StatefulWidget {
  const UsagePage({super.key});

  @override
  State<UsagePage> createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;

  bool _isLoading = true;
  Map<String, dynamic> _todayData = {};
  Map<String, dynamic> _weekData = {};
  Map<String, dynamic> _monthData = {};
  List<Map<String, dynamic>> _deviceUsage = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadUsageData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUsageData() async {
    try {
      await Future.wait([
        _calculateTodayUsage(),
        _calculateWeekUsage(),
        _calculateMonthUsage(),
        _calculateDeviceUsage(),
      ]);
      _animationController.forward(from: 0);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading usage data: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateTodayUsage() async {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    double totalKWh = await _calculateUsageForPeriod(todayStart, todayEnd);

    if (mounted) {
      _todayData = {'kwh': totalKWh, 'cost': totalKWh * 7.50};
    }
  }

  Future<void> _calculateWeekUsage() async {
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: 7));

    double totalKWh = await _calculateUsageForPeriod(weekStart, now);

    if (mounted) {
      _weekData = {'kwh': totalKWh, 'cost': totalKWh * 7.50};
    }
  }

  Future<void> _calculateMonthUsage() async {
    DateTime now = DateTime.now();
    DateTime monthStart = DateTime(now.year, now.month, 1);

    double totalKWh = await _calculateUsageForPeriod(monthStart, now);

    if (mounted) {
      _monthData = {'kwh': totalKWh, 'cost': totalKWh * 7.50};
    }
  }

  Future<double> _calculateUsageForPeriod(DateTime start, DateTime end) async {
    double totalWattsUsed = 0.0;
    int totalDurationSeconds = 0;

    try {
      QuerySnapshot homesSnapshot = await _getUserHomes();

      for (var homeDoc in homesSnapshot.docs) {
        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeDoc.id)
            .collection('Equipments')
            .get();

        for (var equipmentDoc in equipmentSnapshot.docs) {
          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeDoc.id)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              .where('startTime', isGreaterThanOrEqualTo: start)
              .where('startTime', isLessThanOrEqualTo: end)
              .get();

          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            totalWattsUsed += (data['wattsUsed'] ?? 0.0) as double;
            totalDurationSeconds += (data['durationSeconds'] ?? 0) as int;
          }
        }
      }

      return (totalWattsUsed * totalDurationSeconds) / 3600000;
    } catch (e) {
      print('Error calculating usage: $e');
      return 0.0;
    }
  }

  Future<void> _calculateDeviceUsage() async {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    List<Map<String, dynamic>> devices = [];

    try {
      QuerySnapshot homesSnapshot = await _getUserHomes();

      for (var homeDoc in homesSnapshot.docs) {
        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeDoc.id)
            .collection('Equipments')
            .get();

        for (var equipmentDoc in equipmentSnapshot.docs) {
          var equipmentData = equipmentDoc.data() as Map<String, dynamic>;
          String deviceName = equipmentData['name'] ?? 'Unknown Device';
          String deviceType = equipmentData['type'] ?? 'device';

          double deviceWatts = 0.0;
          int deviceDuration = 0;

          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeDoc.id)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              .where('startTime', isGreaterThanOrEqualTo: todayStart)
              .where('startTime', isLessThanOrEqualTo: todayEnd)
              .get();

          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            deviceWatts += (data['wattsUsed'] ?? 0.0) as double;
            deviceDuration += (data['durationSeconds'] ?? 0) as int;
          }

          double deviceKWh = (deviceWatts * deviceDuration) / 3600000;

          if (deviceKWh > 0) {
            devices.add({
              'name': deviceName,
              'type': deviceType,
              'kwh': deviceKWh,
              'icon': _getIconForDeviceType(deviceType),
              'color': _getColorForDeviceType(deviceType),
            });
          }
        }
      }

      devices.sort((a, b) => b['kwh'].compareTo(a['kwh']));

      setState(() {
        _deviceUsage = devices;
      });
    } catch (e) {
      print('Error calculating device usage: $e');
    }
  }

  IconData _getIconForDeviceType(String type) {
    switch (type.toLowerCase()) {
      case 'bulb':
      case 'light':
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'fan':
        return Icons.air;
      case 'ac':
      case 'air conditioner':
        return Icons.ac_unit;
      case 'tv':
      case 'television':
        return Icons.tv;
      case 'refrigerator':
      case 'fridge':
        return Icons.kitchen;
      case 'heater':
        return Icons.local_fire_department;
      case 'washing machine':
        return Icons.local_laundry_service;
      default:
        return Icons.power;
    }
  }

  Color _getColorForDeviceType(String type) {
    switch (type.toLowerCase()) {
      case 'bulb':
      case 'light':
      case 'lamp':
        return Colors.amber;
      case 'fan':
        return Colors.cyan;
      case 'ac':
      case 'air conditioner':
        return Colors.blue;
      case 'tv':
      case 'television':
        return Colors.purple;
      case 'refrigerator':
      case 'fridge':
        return Colors.teal;
      case 'heater':
        return Colors.deepOrange;
      case 'washing machine':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Future<QuerySnapshot> _getUserHomes() async {
    final user = Appvariables.loggedInUser;
    if (user == null) {
      return await _firestore
          .collection('Homes')
          .where('status', isEqualTo: 1)
          .where('userId', isEqualTo: null)
          .get();
    }

    if (user.memberType != null &&
        user.homeId != null &&
        user.homeId!.isNotEmpty) {
      return await _firestore
          .collection('Homes')
          .where('status', isEqualTo: 1)
          .where('homeId', isEqualTo: user.homeId)
          .get();
    }

    return await _firestore
        .collection('Homes')
        .where('status', isEqualTo: 1)
        .where('userId', isEqualTo: user.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Usage Overview",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadUsageData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16.h),
                  Text(
                    "Loading usage data...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUsageData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Enhanced Header Card
                    _buildHeaderCard(),

                    // Summary Cards
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _enhancedSummaryCard(
                                  "This Week",
                                  "${(_weekData['kwh'] ?? 0.0).toStringAsFixed(1)}",
                                  "kWh",
                                  Icons.calendar_today_rounded,
                                  Colors.blue,
                                  "₹${(_weekData['cost'] ?? 0.0).toStringAsFixed(2)}",
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _enhancedSummaryCard(
                                  "This Month",
                                  "${(_monthData['kwh'] ?? 0.0).toStringAsFixed(1)}",
                                  "kWh",
                                  Icons.date_range_rounded,
                                  Colors.purple,
                                  "₹${(_monthData['cost'] ?? 0.0).toStringAsFixed(2)}",
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          // Device Usage Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Top Consumers",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (_deviceUsage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    "${_deviceUsage.length} devices",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          _deviceUsage.isEmpty
                              ? _buildEmptyState()
                              : Column(
                                  children: _deviceUsage.asMap().entries.map((
                                    entry,
                                  ) {
                                    int index = entry.key;
                                    var device = entry.value;
                                    return _modernDeviceTile(
                                      device['name'],
                                      device['kwh'],
                                      device['icon'],
                                      device['color'],
                                      index,
                                    );
                                  }).toList(),
                                ),

                          SizedBox(height: 24.h),

                          // Analytics Section
                          Text(
                            "Analytics",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Updated analytics buttons - now 3 in a row
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _modernAnalyticsButton(
                                      "Daily Trends",
                                      Icons.insights_rounded,
                                      Colors.orange,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DailyDeviceGraphPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _modernAnalyticsButton(
                                      "Weekly Report",
                                      Icons.bar_chart_rounded,
                                      Colors.green,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WeeklyDeviceGraphPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              // Monthly report button - full width
                              _modernAnalyticsButton(
                                "Monthly Report",
                                Icons.calendar_month_rounded,
                                Colors.deepPurple,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MonthlyDeviceGraphPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    double todayKwh = _todayData['kwh'] ?? 0.0;
    double todayCost = _todayData['cost'] ?? 0.0;
    double percentage = (todayKwh / 10).clamp(
      0.0,
      1.0,
    ); // Assume 10kWh daily limit

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade400,
            Colors.cyan.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20.r,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Usage",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        todayKwh.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          "kWh",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        Text(
                          todayCost.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100.h,
                width: 100.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 10.w,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(percentage * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "of limit",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _enhancedSummaryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1,
                ),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernDeviceTile(
    String name,
    double kwh,
    IconData icon,
    Color color,
    int index,
  ) {
    final maxKwh = _deviceUsage.isNotEmpty ? _deviceUsage[0]['kwh'] : 1.0;
    final percentage = (kwh / maxKwh).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: color, size: 28.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${kwh.toStringAsFixed(2)} kWh",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "₹${(kwh * 7.50).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8.h,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernAnalyticsButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.sp, color: color),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.power_off_rounded,
            size: 64.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Usage Today",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start using your devices to see\nusage statistics here",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
