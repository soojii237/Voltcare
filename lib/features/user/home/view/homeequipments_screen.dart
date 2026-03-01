// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/helper/helper_icons.dart';
import 'adddeviceunderhome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voltcare/service/cloudinary_service.dart';
import '../service/calculator_user.dart';

class HomeDevicesScreen extends StatefulWidget {
  final String homeId; // Pass home document ID from previous screen
  final String homeName;
  final Color homeColor;
  final IconData homeIcon;

  const HomeDevicesScreen({
    super.key,
    required this.homeId,
    required this.homeName,
    required this.homeColor,
    required this.homeIcon,
  });

  @override
  State<HomeDevicesScreen> createState() => _HomeDevicesScreenState();
}

class _HomeDevicesScreenState extends State<HomeDevicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.homeColor.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.homeColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.homeName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.homeColor,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: widget.homeColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDeviceScreen(
                    homeId: widget.homeId,
                    homeColor: widget.homeColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Homes')
            .doc(widget.homeId)
            .collection('Equipments')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: widget.homeColor),
            );
          }

          final devices = snapshot.data?.docs ?? [];
          final activeCount = devices.where((doc) {
            return doc['isOn'] == true;
          }).length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.homeColor.withOpacity(0.15),
                        widget.homeColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Load home doc to show image and limit
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Homes')
                            .doc(widget.homeId)
                            .snapshots(),
                        builder: (context, homeSnap) {
                          if (!homeSnap.hasData || !homeSnap.data!.exists) {
                            return const SizedBox(); // or loading indicator
                          }

                          final homeData =
                              homeSnap.data!.data() as Map<String, dynamic>?;

                          final imageUrl =
                              homeData?['imageUrl'] as String? ?? '';
                          final dailyLimit =
                              (homeData?['dailyUsageLimit'] as num?)
                                  ?.toDouble();

                          Widget avatar;
                          if (imageUrl.isNotEmpty) {
                            avatar = ClipRRect(
                              borderRadius: BorderRadius.circular(80.r),
                              child: Container(
                                width: 80.w,
                                height: 80.w,
                                color: Colors.grey.shade200,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: Colors.grey.shade100,
                                    child: Icon(
                                      widget.homeIcon,
                                      color: widget.homeColor,
                                      size: 40.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            avatar = Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.homeColor.withOpacity(0.3),
                                    blurRadius: 20.r,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.homeIcon,
                                color: widget.homeColor,
                                size: 48.sp,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Stack(
                                children: [
                                  avatar,
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 18.sp,
                                          color: widget.homeColor,
                                        ),
                                        onPressed: () => _editHomeImage(
                                          widget.homeId,
                                          imageUrl,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "${devices.length} Devices",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              FutureBuilder<double>(
                                future: UsageCalculator()
                                    .calculateDailyUsageForHome(widget.homeId),
                                builder: (context, usageSnap) {
                                  final currentUsage = usageSnap.data ?? 0.0;
                                  if (dailyLimit != null && dailyLimit > 0) {
                                    final over = currentUsage >= dailyLimit;
                                    return Text(
                                      over
                                          ? "LIMIT EXCEEDED"
                                          : "${currentUsage.toStringAsFixed(2)} / ${dailyLimit.toStringAsFixed(2)} kWh",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: over
                                            ? Colors.red.shade700
                                            : Colors.grey.shade600,
                                        fontWeight: over
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    );
                                  }
                                  return Text(
                                    "$activeCount Active",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Devices Grid
                devices.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Column(
                          children: [
                            Icon(
                              Icons.devices_other,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No devices added yet',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Tap + to add a device',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16.w),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: devices.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.74,
                              ),
                          itemBuilder: (context, index) {
                            return _buildDeviceCard(devices[index]);
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(QueryDocumentSnapshot deviceDoc) {
    final device = deviceDoc.data() as Map<String, dynamic>;
    final isOn = device['isOn'] ?? false;
    final deviceName = device['name'] ?? 'Unknown Device';
    final wattPerHour = device['wattPerHour'] ?? 0;

    // Use IconHelper instead of dynamic IconData creation
    final deviceIcon = IconHelper.getIcon(
      device['iconCode'],
      defaultIcon: Icons.power,
    );

    return InkWell(
      onTap: () {
        // Navigate to device details if needed
      },
      child: Stack(
        // Changed from Container to Stack to position the delete button
        children: [
          Container(
            width: double
                .infinity, // Ensure container takes full width of the grid cell
            height: double.infinity, // Ensure container takes full height
            decoration: BoxDecoration(
              color: isOn ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isOn ? Colors.blue.shade300 : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isOn ? Colors.blue.shade100 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    deviceIcon,
                    size: 36.sp,
                    color: isOn ? Colors.blue.shade700 : Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 12.h),

                Text(
                  deviceName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  '${wattPerHour}W',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 8.h),

                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isOn,
                    onChanged: (value) => _toggleDevice(deviceDoc.id, value),
                    activeColor: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Delete Button Positioned at Top Right
          Positioned(
            top: 4.h,
            right: 4.w,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade300,
                size: 20.sp,
              ),
              onPressed: () => _confirmDeleteDevice(deviceDoc.id, deviceName),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(), // Removes default padding constraints
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDevice(String deviceId, String deviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete $deviceName?"),
          content: Text("Are you sure you want to delete this device?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice(deviceId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDevice(String deviceId) async {
    try {
      await _firestore
          .collection('Homes')
          .doc(widget.homeId)
          .collection('Equipments')
          .doc(deviceId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting device: $e')));
    }
  }

  Future<void> _toggleDevice(String deviceId, bool newValue) async {
    try {
      final deviceRef = _firestore
          .collection('Homes')
          .doc(widget.homeId)
          .collection('Equipments')
          .doc(deviceId);

      await deviceRef.update({
        'isOn': newValue,
        'lastOn': newValue ? FieldValue.serverTimestamp() : null,
      });

      // If turning on, create a usage log entry
      if (newValue) {
        await deviceRef.collection('usageLogs').add({
          'startTime': FieldValue.serverTimestamp(),
          'endTime': null,
          'durationSeconds': null,
          'wattsUsed': null,
          'cost': null,
          'date': DateTime.now().toIso8601String().split('T')[0],
          'month':
              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
        });
      } else {
        // When turning off, update the last open usage log
        final logsSnapshot = await deviceRef
            .collection('usageLogs')
            .where('endTime', isEqualTo: null)
            .orderBy('startTime', descending: true)
            .limit(1)
            .get();

        if (logsSnapshot.docs.isNotEmpty) {
          final logDoc = logsSnapshot.docs.first;
          final logData = logDoc.data();
          final startTime = (logData['startTime'] as Timestamp).toDate();
          final endTime = DateTime.now();
          final durationSeconds = endTime.difference(startTime).inSeconds;

          // Get device wattage
          final deviceData = (await deviceRef.get()).data();
          final wattPerHour = deviceData?['wattPerHour'] ?? 0;
          final wattsUsed = (wattPerHour * durationSeconds) / 3600;

          // Fetch chargePerWatt from the Homes document
          final homeDoc = await _firestore
              .collection('Homes')
              .doc(widget.homeId)
              .get();

          final homeData = homeDoc.data();
          final chargePerWatt = (homeData?['chargePerWatt'] ?? 0.12).toDouble();

          // Calculate cost using chargePerWatt (convert watts to kWh and multiply by rate)
          final cost = (wattsUsed / 1000) * chargePerWatt;

          await logDoc.reference.update({
            'endTime': FieldValue.serverTimestamp(),
            'durationSeconds': durationSeconds,
            'wattsUsed': wattsUsed,
            'cost': cost,
          });

          // Update equipment totals
          await deviceRef.update({
            'totalSecondsUsed': FieldValue.increment(durationSeconds),
            'totalWattsUsed': FieldValue.increment(wattsUsed),
            'totalCost': FieldValue.increment(cost),
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error toggling device: $e')));
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
                  final file = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1800,
                    maxHeight: 1800,
                    imageQuality: 85,
                  );
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1800,
                    maxHeight: 1800,
                    imageQuality: 85,
                  );
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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final uploaded = await CloudneryUploader().uploadFile(picked);

      Navigator.pop(context);

      if (uploaded == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload failed'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('Homes').doc(homeId).update({
        'imageUrl': uploaded,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Home image updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
