import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyDeviceGraphPage extends StatefulWidget {
  const MonthlyDeviceGraphPage({super.key});

  @override
  State<MonthlyDeviceGraphPage> createState() => _MonthlyDeviceGraphPageState();
}

class _MonthlyDeviceGraphPageState extends State<MonthlyDeviceGraphPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, List<double>> _deviceMonthlyData = {};
  List<String> _deviceNames = [];
  double _maxKwh = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() => _isLoading = true);

    try {
      DateTime now = DateTime.now();
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      Map<String, List<double>> deviceData = {};

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

          if (!deviceData.containsKey(deviceName)) {
            deviceData[deviceName] = List.filled(daysInMonth, 0.0);
          }

          for (int day = 1; day <= daysInMonth; day++) {
            DateTime dayStart = DateTime(now.year, now.month, day, 0, 0, 0);
            DateTime dayEnd = DateTime(now.year, now.month, day, 23, 59, 59);

            // Skip future dates
            if (dayStart.isAfter(now)) continue;

            QuerySnapshot usageLogsSnapshot = await _firestore
                .collection('Homes')
                .doc(homeDoc.id)
                .collection('Equipments')
                .doc(equipmentDoc.id)
                .collection('usageLogs')
                .where('startTime', isGreaterThanOrEqualTo: dayStart)
                .where('startTime', isLessThanOrEqualTo: dayEnd)
                .get();

            double dayKwh = 0.0;
            for (var logDoc in usageLogsSnapshot.docs) {
              var data = logDoc.data() as Map<String, dynamic>;
              double wattsUsed = (data['wattsUsed'] ?? 0.0) as double;
              int durationSeconds = (data['durationSeconds'] ?? 0) as int;
              dayKwh += (wattsUsed * durationSeconds) / 3600000;
            }

            deviceData[deviceName]![day - 1] = dayKwh;

            if (dayKwh > _maxKwh) {
              _maxKwh = dayKwh;
            }
          }
        }
      }

      // Filter out devices with no usage
      deviceData.removeWhere((key, value) => value.every((kwh) => kwh == 0.0));

      setState(() {
        _deviceMonthlyData = deviceData;
        _deviceNames = deviceData.keys.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading monthly data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Color> _getDeviceColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    String monthName = _getMonthName(now.month);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Monthly Report - $monthName",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMonthlyData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16.h),
                  Text(
                    "Loading monthly data...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : _deviceNames.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      _buildSummaryCard(),
                      SizedBox(height: 24.h),

                      // Line Chart
                      Text(
                        "Daily Usage Trends",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildLineChart(daysInMonth),

                      SizedBox(height: 24.h),

                      // Device Legend
                      Text(
                        "Devices",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildDeviceLegend(),

                      SizedBox(height: 24.h),

                      // Total by Device
                      Text(
                        "Total Usage by Device",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildDeviceTotals(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    double totalKwh = 0.0;
    _deviceMonthlyData.forEach((device, data) {
      totalKwh += data.reduce((a, b) => a + b);
    });

    double totalCost = totalKwh * 7.50;
    double avgDaily = totalKwh / DateTime.now().day;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade400,
            Colors.purple.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total This Month",
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
                          totalKwh.toStringAsFixed(1),
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
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Icons.currency_rupee,
                            color: Colors.white, size: 18.sp),
                        Text(
                          totalCost.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Icon(Icons.analytics_outlined,
                        color: Colors.white, size: 32.sp),
                    SizedBox(height: 8.h),
                    Text(
                      "${avgDaily.toStringAsFixed(1)} kWh",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "avg/day",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.8),
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

  Widget _buildLineChart(int daysInMonth) {
    List<Color> colors = _getDeviceColors();

    return Container(
      height: 300.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _maxKwh > 0 ? _maxKwh / 5 : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.w,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
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
                reservedSize: 30.h,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 5 == 0 && value.toInt() > 0) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 1,
          maxX: daysInMonth.toDouble(),
          minY: 0,
          maxY: _maxKwh * 1.2,
          lineBarsData: _deviceNames.asMap().entries.map((entry) {
            int index = entry.key;
            String deviceName = entry.value;
            List<double> data = _deviceMonthlyData[deviceName]!;

            return LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot((i + 1).toDouble(), data[i]),
              ),
              isCurved: true,
              color: colors[index % colors.length],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: colors[entry.key % colors.length],
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: colors[index % colors.length].withOpacity(0.1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeviceLegend() {
    List<Color> colors = _getDeviceColors();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 12.h,
        children: _deviceNames.asMap().entries.map((entry) {
          int index = entry.key;
          String deviceName = entry.value;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                deviceName,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeviceTotals() {
    List<Color> colors = _getDeviceColors();
    List<MapEntry<String, double>> totals = [];

    _deviceMonthlyData.forEach((device, data) {
      double total = data.reduce((a, b) => a + b);
      totals.add(MapEntry(device, total));
    });

    totals.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: totals.asMap().entries.map((entry) {
        int index = _deviceNames.indexOf(entry.value.key);
        String deviceName = entry.value.key;
        double totalKwh = entry.value.value;
        double cost = totalKwh * 7.50;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: colors[index % colors.length].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    "${entry.key + 1}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: colors[index % colors.length],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${totalKwh.toStringAsFixed(2)} kWh",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "₹${cost.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colors[index % colors.length],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40.w),
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              "No Data Available",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "No usage data found for this month",
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}