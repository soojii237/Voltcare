// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:voltcare/utils/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  bool _isLoading = true;
  List<Map<String, dynamic>> _homeUsageData = [];
  List<Map<String, dynamic>> _userUsageData = [];
  String _selectedPeriod = 'Today';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDates();
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeDates() {
    DateTime now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        _startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Week':
        _startDate = now.subtract(Duration(days: 7));
        _endDate = now;
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'All Time':
        _startDate = DateTime(2020, 1, 1);
        _endDate = now;
        break;
    }
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadHomeUsageData(),
        _loadUserUsageData(),
      ]);
    } catch (e) {
      print('Error loading admin data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHomeUsageData() async {
    List<Map<String, dynamic>> homeData = [];

    try {
      QuerySnapshot homesSnapshot = await _firestore.collection('Homes').get();

      for (var homeDoc in homesSnapshot.docs) {
        var homeInfo = homeDoc.data() as Map<String, dynamic>;
        String homeName = homeInfo['name'] ?? 'Unnamed Home';
        String homeId = homeDoc.id;
        String userId = homeInfo['userId'] ?? 'Unknown';

        // Get user info
        String userName = 'Unknown User';
        String userEmail = '';
        try {
          DocumentSnapshot userDoc =
              await _firestore.collection('Users').doc(userId).get();
          if (userDoc.exists) {
            var userData = userDoc.data() as Map<String, dynamic>;
            userName = userData['name'] ?? userData['displayName'] ?? 'Unknown User';
            userEmail = userData['email'] ?? '';
          }
        } catch (e) {
          print('Error fetching user: $e');
        }

        // Calculate usage for this home
        double totalKWh = 0.0;
        int deviceCount = 0;
        Map<String, double> deviceBreakdown = {};

        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeId)
            .collection('Equipments')
            .get();

        deviceCount = equipmentSnapshot.docs.length;

        for (var equipmentDoc in equipmentSnapshot.docs) {
          var equipmentData = equipmentDoc.data() as Map<String, dynamic>;
          String deviceName = equipmentData['name'] ?? 'Unknown';

          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeId)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              .where('startTime', isGreaterThanOrEqualTo: _startDate)
              .where('startTime', isLessThanOrEqualTo: _endDate)
              .get();

          double deviceKWh = 0.0;
          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            double watts = (data['wattsUsed'] ?? 0.0) as double;
            int duration = (data['durationSeconds'] ?? 0) as int;
            deviceKWh += (watts * duration) / 3600000;
          }

          totalKWh += deviceKWh;
          if (deviceKWh > 0) {
            deviceBreakdown[deviceName] = deviceKWh;
          }
        }

        if (totalKWh > 0 || deviceCount > 0) {
          homeData.add({
            'homeId': homeId,
            'homeName': homeName,
            'userId': userId,
            'userName': userName,
            'userEmail': userEmail,
            'kwh': totalKWh,
            'cost': totalKWh * 7.50,
            'deviceCount': deviceCount,
            'deviceBreakdown': deviceBreakdown,
          });
        }
      }

      homeData.sort((a, b) => b['kwh'].compareTo(a['kwh']));
      setState(() => _homeUsageData = homeData);
    } catch (e) {
      print('Error loading home usage data: $e');
    }
  }

  Future<void> _loadUserUsageData() async {
    Map<String, Map<String, dynamic>> userDataMap = {};

    try {
      QuerySnapshot homesSnapshot = await _firestore.collection('Homes').get();

      for (var homeDoc in homesSnapshot.docs) {
        var homeInfo = homeDoc.data() as Map<String, dynamic>;
        String userId = homeInfo['userId'] ?? 'Unknown';
        String homeName = homeInfo['name'] ?? 'Unnamed Home';

        if (!userDataMap.containsKey(userId)) {
          // Get user info
          String userName = 'Unknown User';
          String userEmail = '';
          try {
            DocumentSnapshot userDoc =
                await _firestore.collection('Users').doc(userId).get();
            if (userDoc.exists) {
              var userData = userDoc.data() as Map<String, dynamic>;
              userName = userData['name'] ?? userData['displayName'] ?? 'Unknown User';
              userEmail = userData['email'] ?? '';
            }
          } catch (e) {
            print('Error fetching user: $e');
          }

          userDataMap[userId] = {
            'userId': userId,
            'userName': userName,
            'userEmail': userEmail,
            'totalKwh': 0.0,
            'totalCost': 0.0,
            'homeCount': 0,
            'homes': <Map<String, dynamic>>[],
          };
        }

        // Calculate usage for this home
        double homeKWh = 0.0;
        int deviceCount = 0;

        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeDoc.id)
            .collection('Equipments')
            .get();

        deviceCount = equipmentSnapshot.docs.length;

        for (var equipmentDoc in equipmentSnapshot.docs) {
          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeDoc.id)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              .where('startTime', isGreaterThanOrEqualTo: _startDate)
              .where('startTime', isLessThanOrEqualTo: _endDate)
              .get();

          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            double watts = (data['wattsUsed'] ?? 0.0) as double;
            int duration = (data['durationSeconds'] ?? 0) as int;
            homeKWh += (watts * duration) / 3600000;
          }
        }

        userDataMap[userId]!['totalKwh'] += homeKWh;
        userDataMap[userId]!['totalCost'] += homeKWh * 7.50;
        userDataMap[userId]!['homeCount'] += 1;
        userDataMap[userId]!['homes'].add({
          'homeName': homeName,
          'kwh': homeKWh,
          'deviceCount': deviceCount,
        });
      }

      List<Map<String, dynamic>> userList = userDataMap.values.toList();
      userList.sort((a, b) => b['totalKwh'].compareTo(a['totalKwh']));
      
      setState(() => _userUsageData = userList);
    } catch (e) {
      print('Error loading user usage data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Admin Reports",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "By Home"),
            Tab(text: "By User"),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.calendar_today_rounded),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
                _initializeDates();
              });
              _loadAdminData();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Today', child: Text('Today')),
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'This Month', child: Text('This Month')),
              PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAdminData,
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
                    "Loading admin data...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHomeTab(),
                _buildUserTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    double totalKWh = _homeUsageData.fold(0.0, (sum, item) => sum + item['kwh']);
    double totalCost = totalKWh * 7.50;
    int totalHomes = _homeUsageData.length;
    int totalUsers = _userUsageData.length;
    int totalDevices = _homeUsageData.fold(0, (sum, item) => sum + (item['deviceCount'] as int));

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _selectedPeriod,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Total Usage Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20.r,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Energy Consumption",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalKWh.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          "kWh",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "₹${totalCost.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Users",
                    totalUsers.toString(),
                    Icons.people_rounded,
                    AppColors.iconYellow,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    "Homes",
                    totalHomes.toString(),
                    Icons.home_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Devices",
                    totalDevices.toString(),
                    Icons.devices_rounded,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    "Avg/Home",
                    totalHomes > 0
                        ? (totalKWh / totalHomes).toStringAsFixed(1)
                        : "0",
                    Icons.analytics_rounded,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Top Consumers
            Text(
              "Top 5 Energy Consumers",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12.h),

            if (_homeUsageData.isEmpty)
              _buildEmptyState()
            else
              ..._homeUsageData.take(5).map((home) => _buildTopConsumerTile(home)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      child: _homeUsageData.isEmpty
          ? Center(child: _buildEmptyState())
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _homeUsageData.length,
              itemBuilder: (context, index) {
                var home = _homeUsageData[index];
                return _buildHomeCard(home, index);
              },
            ),
    );
  }

  Widget _buildUserTab() {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      child: _userUsageData.isEmpty
          ? Center(child: _buildEmptyState())
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _userUsageData.length,
              itemBuilder: (context, index) {
                var user = _userUsageData[index];
                return _buildUserCard(user, index);
              },
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopConsumerTile(Map<String, dynamic> home) {
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.home_rounded, color: Colors.orange, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  home['homeName'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  home['userName'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${home['kwh'].toStringAsFixed(2)} kWh",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "₹${home['cost'].toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard(Map<String, dynamic> home, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.iconYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.home_rounded, color: AppColors.iconYellow, size: 24.sp),
        ),
        title: Text(
          home['homeName'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              home['userName'],
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
            if (home['userEmail'].isNotEmpty)
              Text(
                home['userEmail'],
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${home['kwh'].toStringAsFixed(2)} kWh",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "₹${home['cost'].toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.devices_rounded, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text(
                      "${home['deviceCount']} Devices",
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                if (home['deviceBreakdown'].isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    "Device Breakdown:",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...home['deviceBreakdown'].entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          Text(
                            "${entry.value.toStringAsFixed(2)} kWh",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Icon(Icons.person, color: Colors.purple, size: 24.sp),
        ),
        title: Text(
          user['userName'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['userEmail'].isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                user['userEmail'],
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
              ),
            ],
            SizedBox(height: 4.h),
            Text(
              "${user['homeCount']} Home(s)",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${user['totalKwh'].toStringAsFixed(2)} kWh",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "₹${user['totalCost'].toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Homes:",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                ...user['homes'].map<Widget>((home) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                home['homeName'],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${home['deviceCount']} devices",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${home['kwh'].toStringAsFixed(2)} kWh",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 64.sp, color: Colors.grey.shade300),
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
            "No usage data found for the selected period",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}