// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voltcare/features/user/home/view/newhomecreation_screen.dart';
import 'package:voltcare/features/widgets/apptext.dart';
import 'package:voltcare/utils/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voltcare/service/cloudinary_service.dart';
import 'package:voltcare/utils/helper/helper_icons.dart' show IconHelper;
import 'package:voltcare/utils/helper/helper_pagenavigator.dart';
import '../../../../utils/dynamic/appvariables.dart';
import '../service/calculator_user.dart';
import 'homeequipments_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  

  UsageCalculator calculator = UsageCalculator();
  String weeklyUsage = "Loading...";
  @override
  void initState() {
    _loadWeeklyUsage();

    super.initState();
  }

  void _loadWeeklyUsage() async {
    var result = await calculator.calculateWeeklyUsage();
    if (mounted) {
      setState(() {
        weeklyUsage = "${result['weeklyKWh']?.toStringAsFixed(1) ?? '0.0'} kWh";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const SizedBox(),
        title: Text(
          "VoltCare",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
            fontSize: 24.sp,
          ),
        ),
        actions: [],
      ),
      body: _buildHomePage(),
      floatingActionButton: Appvariables.loggedInUser?.memberType == null
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blue.shade600,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNewHomeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const AppText(text: "Add Home", color: AppColors.white),
            )
          : null,
    );
  }

  Stream<QuerySnapshot> _userHomesStream() {
    final user = Appvariables.loggedInUser;
    if (user == null) {
      return FirebaseFirestore.instance
          .collection('Homes')
          .where('status', isEqualTo: 1)
          .where('userId', isEqualTo: null)
          .snapshots();
    }

    if (user.memberType != null &&
        user.homeId != null &&
        user.homeId!.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('Homes')
          .where('status', isEqualTo: 1)
          .where('homeId', isEqualTo: user.homeId)
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('Homes')
        .where('status', isEqualTo: 1)
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  // ============ HOME PAGE ============
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Daily Summary Card
          _buildEnhancedUsageCard(),

          SizedBox(height: 24.h),

          // Quick Stats Row
          _buildQuickStats(),

          SizedBox(height: 24.h),

          // Homes Section Header
          StreamBuilder(
            stream: _userHomesStream(),
            builder: (context, asyncSnapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Homes",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        "${asyncSnapshot.data != null ? asyncSnapshot.data?.docs.length : 0} locations",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // List of Homes (cards only, no devices)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: asyncSnapshot.data != null
                        ? asyncSnapshot.data?.docs.length
                        : 0,
                    itemBuilder: (context, index) {
                      var homeData = asyncSnapshot.data!.docs[index];
                      return _buildHomeCard(homeData);
                    },
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ============ HOME CARD (simplified - no devices grid) ============
  Widget _buildHomeCard(QueryDocumentSnapshot<Object?> homeData) {
    final home = homeData;

    // Use IconHelper instead of dynamic IconData creation
    final homeIcon = IconHelper.getIcon(
      home['iconCodePoint'],
      defaultIcon: Icons.home,
    );

    final homeColor = Color(int.parse(home['backgroundColor'].toString()));

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Screen.open(
            context,
            HomeDevicesScreen(
              homeId: home.id,
              homeName: home['name'],
              homeColor: homeColor,
              homeIcon: homeIcon,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Home image or icon
              Builder(builder: (context) {
                final data = home.data() as Map<String, dynamic>;
                final imageUrl = (data['imageUrl'] as String?) ?? '';
                if (imageUrl.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: 64.w,
                      height: 64.w,
                      color: Colors.grey.shade200,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(homeIcon, color: homeColor, size: 28.sp),
                        ),
                      ),
                    ),
                  );
                }

                return Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        homeColor.withOpacity(0.3),
                        homeColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(homeIcon, color: homeColor, size: 32.sp),
                );
              }),

              SizedBox(width: 16.w),

              // Home details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            home['name'] ?? 'Unnamed Home',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FutureBuilder<double>(
                          future: UsageCalculator().calculateDailyUsageForHome(
                            home.id,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final currentUsage = snapshot.data!;
                              final limit =
                                  (home.data()
                                          as Map<
                                            String,
                                            dynamic
                                          >)['dailyUsageLimit']
                                      ?.toDouble() ??
                                  0.0;

                              if (limit > 0 && currentUsage >= limit) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    "LIMIT EXCEEDED",
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Homes')
                              .doc(home.id)
                              .collection('Equipments')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Text("0 devices");
                            final count = snapshot.data!.docs.length;
                            return Text("$count devices");
                          },
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit image


              // Delete icon
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 24.sp,
                ),
                onPressed: () => _confirmDeleteHome(home.id, home['name']),
              ),

              SizedBox(width: 4.w),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteHome(String homeId, String homeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete $homeName?"),
          content: Text(
            "Are you sure you want to delete this home? All devices and data associated with it will be lost.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHome(homeId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHome(String homeId) async {
    try {
      // 1. Delete all subcollections (Equipments) manually if needed,
      // but client-side Firestore deletes don't automatically recurse.
      // For a simple app, we might just delete the Home document
      // and let the subcollections become orphaned or handle it via Cloud Functions.
      // Here, we'll try to delete equipments first for cleanliness.

      final equipments = await FirebaseFirestore.instance
          .collection('Homes')
          .doc(homeId)
          .collection('Equipments')
          .get();

      for (var doc in equipments.docs) {
        await doc.reference.delete();
      }

      // 2. Delete the Home document
      await FirebaseFirestore.instance.collection('Homes').doc(homeId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Home deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting home: $e')));
    }
  }

  Future<void> _editHomeImage(String homeId, String currentUrl) async {
    try {
      final picker = ImagePicker();
      final picked = await showModalBottomSheet<XFile?>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  final file = await picker.pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context, null),
              ),
            ],
          ),
        ),
      );

      if (picked == null) return;

      // show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final uploaded = await CloudneryUploader().uploadFile(picked);

      Navigator.pop(context); // remove loading

      if (uploaded == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed'), backgroundColor: Colors.red));
        return;
      }

      await FirebaseFirestore.instance.collection('Homes').doc(homeId).update({'imageUrl': uploaded});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Home image updated'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating image: $e'), backgroundColor: Colors.red));
    }
  }

  Future<int> getEquipmentsCount(String homeId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Homes') // your main collection (replace if different)
        .doc(homeId)
        .collection('Equipments')
        .get();

    return snapshot.docs.length;
  }

  // ============ ENHANCED USAGE CARD ============
  Widget _buildEnhancedUsageCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: UsageCalculator().calculateTodayUsage(),
      builder: (context, snapshot) {
        double kwh = 0.0;
        double cost = 0.0;
        double percentage = 0.0;

        if (snapshot.hasData && snapshot.data != null) {
          kwh = snapshot.data!['todayKWh'] ?? 0.0;
          cost = snapshot.data!['estimatedCost'] ?? 0.0;
          // Calculate percentage based on a daily limit (e.g., 3.2 kWh)
          percentage = (kwh / 3.2).clamp(0.0, 1.0);
        }

        return Container(
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
                blurRadius: 12.r,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Circular usage indicator
              SizedBox(
                height: 90.h,
                width: 90.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 8.w,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                    ),
                    Center(
                      child: Text(
                        "${(percentage * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 20.w),

              // Usage details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Usage",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.white, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "${kwh.toStringAsFixed(5)} kWh",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "${cost.toStringAsFixed(2)} estimated",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ QUICK STATS ROW ============
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: _userHomesStream(),
            builder: (context, asyncSnapshot) {
              return _buildStatCard(
                icon: Icons.home_work,
                label: "Total Homes",
                value:
                    "${asyncSnapshot.data != null ? asyncSnapshot.data?.docs.length : 0}",
                color: Colors.purple,
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: StreamBuilder(
            stream: _userHomesStream(),
            builder: (context, homeSnapshot) {
              if (!homeSnapshot.hasData) {
                return _buildStatCard(
                  icon: Icons.devices,
                  label: "Active Devices",
                  value: "0",
                  color: Colors.green,
                );
              }

              final homes = homeSnapshot.data!.docs;

              if (homes.isEmpty) {
                return _buildStatCard(
                  icon: Icons.devices,
                  label: "Active Devices",
                  value: "0",
                  color: Colors.green,
                );
              }

              // list of all equipment streams
              List<Stream<QuerySnapshot>> equipmentStreams = homes.map((home) {
                return FirebaseFirestore.instance
                    .collection('Homes')
                    .doc(home.id)
                    .collection('Equipments')
                    .snapshots();
              }).toList();

              // combine all equipment streams
              return StreamBuilder(
                stream: CombineLatestStream.list(equipmentStreams),
                builder: (context, equipmentSnapshot) {
                  if (!equipmentSnapshot.hasData) {
                    return _buildStatCard(
                      icon: Icons.devices,
                      label: "Active Devices",
                      value: "0",
                      color: Colors.green,
                    );
                  }

                  int activeDevices = 0;

                  // equipmentSnapshot.data is a list of QuerySnapshot
                  for (var equipSnap in equipmentSnapshot.data!) {
                    for (var doc in equipSnap.docs) {
                      if (doc['isOn'] == true) {
                        activeDevices++;
                      }
                    }
                  }

                  return _buildStatCard(
                    icon: Icons.devices,
                    label: "Active Devices",
                    value: "$activeDevices",
                    color: Colors.green,
                  );
                },
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: StreamBuilder(
            stream: _userHomesStream(),
            builder: (context, asyncSnapshot) {
              // Reload usage when homes data changes
              if (asyncSnapshot.hasData) {
                _loadWeeklyUsage();
              }

              return _buildStatCard(
                icon: Icons.trending_up,
                label: "Total Usage",
                value: weeklyUsage,
                color: Colors.orange,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
