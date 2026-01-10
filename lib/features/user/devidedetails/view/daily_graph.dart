import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyDeviceGraphPage extends StatefulWidget {
  const DailyDeviceGraphPage({super.key});

  @override
  State<DailyDeviceGraphPage> createState() => _DailyDeviceGraphPageState();
}

class _DailyDeviceGraphPageState extends State<DailyDeviceGraphPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _deviceData = [];
  double _totalUsage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      DateTime now = DateTime.now();
      DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      List<Map<String, dynamic>> devices = [];
      double total = 0.0;

      QuerySnapshot homesSnapshot = await _firestore.collection('Homes').get();

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
              'color': _getColorForDeviceType(deviceType),
            });
            total += deviceKWh;
          }
        }
      }

      // Sort by highest usage
      devices.sort((a, b) => b['kwh'].compareTo(a['kwh']));

      if (mounted) {
        _deviceData = devices;
        _totalUsage = total;
      }
    } catch (e) {
      print('Error loading daily data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Daily Device Usage",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDailyData,
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
                    "Loading device data...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : _deviceData.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDailyData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15.r,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "Today's Total Usage",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _totalUsage.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 6.h),
                                    child: Text(
                                      "kWh",
                                      style: TextStyle(
                                        fontSize: 18.sp,
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
                                      "${(_totalUsage * 7.50).toStringAsFixed(2)} estimated cost",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        Text(
                          "Energy Consumption by Device",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Bar Chart
                        Container(
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
                          child: SizedBox(
                            height: 300.h,
                            child: BarChart(
                              BarChartData(
                                maxY: (_deviceData.isNotEmpty
                                        ? _deviceData[0]['kwh']
                                        : 1.0) *
                                    1.2,
                                minY: 0,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 45.w,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          "${value.toStringAsFixed(1)}\nkWh",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 &&
                                            index < _deviceData.length) {
                                          return Padding(
                                            padding: EdgeInsets.only(top: 8.h),
                                            child: Text(
                                              _deviceData[index]['name']
                                                          .toString()
                                                          .length >
                                                      8
                                                  ? _deviceData[index]['name']
                                                      .toString()
                                                      .substring(0, 8)
                                                  : _deviceData[index]['name'],
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(
                                  _deviceData.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: _deviceData[index]['kwh'],
                                        width: 28.w,
                                        gradient: LinearGradient(
                                          colors: [
                                            _deviceData[index]['color'],
                                            _deviceData[index]['color']
                                                .withOpacity(0.7),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex,
                                        rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${_deviceData[groupIndex]['name']}\n${_deviceData[groupIndex]['kwh'].toStringAsFixed(2)} kWh',
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Device Details List
                        Text(
                          "Device Breakdown",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        ..._deviceData.map((device) {
                          double percentage = (device['kwh'] / _totalUsage) * 100;
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: device['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    _getIconForDeviceType(device['type']),
                                    color: device['color'],
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device['name'],
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "${device['kwh'].toStringAsFixed(2)} kWh • ${percentage.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey.shade600,
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
                                    color: device['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    "₹${(device['kwh'] * 7.50).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: device['color'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(40.w),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 80.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              "No Data Available",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Start using your devices to see\ndaily usage statistics",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}