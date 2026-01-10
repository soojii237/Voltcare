// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/features/widgets/apptext.dart';

import '../../../widgets/apptextfeild.dart';

class AddDeviceScreen extends StatefulWidget {
  final String homeId;
  final Color homeColor;

  const AddDeviceScreen({
    Key? key,
    required this.homeId,
    required this.homeColor,
  }) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _wattController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();
  String? selectedDeviceId;
  bool isLoading = false;
  String searchQuery = '';

  @override
  void dispose() {
    _wattController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
          'Add Device',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.homeColor,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppTextField(
              controller: _searchController,
              label: 'Search',
              hintText: 'Search devices...',
              showLabelOutside: false,
              enabled: !isLoading,
              prefixIcon: Icon(
                Icons.search,
                color: widget.homeColor,
                size: 20.sp,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Device List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Equipments').where('namefilter',arrayContains: _searchController.text.isEmpty?null:_searchController.text.toLowerCase()).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: widget.homeColor),
                  );
                }

                var allDevices = snapshot.data?.docs ?? [];


                if (allDevices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.devices_other, size: 64.sp, color: Colors.grey),
                        SizedBox(height: 16.h),
                        Text(
                          searchQuery.isNotEmpty 
                              ? 'No devices found' 
                              : 'No devices available',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: allDevices.length,
                  itemBuilder: (context, index) {
                    final device = allDevices[index];
                    final deviceData = device.data() as Map<String, dynamic>;
                    final isSelected = selectedDeviceId == device.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDeviceId = device.id;
                        });
                        _deviceController.text = deviceData['name'] ?? '';
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.homeColor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? widget.homeColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.grey.shade200,
                                image: deviceData['image'] != null &&
                                        deviceData['image'].toString().isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(deviceData['image']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: deviceData['image'] == null ||
                                      deviceData['image'].toString().isEmpty
                                  ? Icon(
                                      Icons.devices,
                                      size: 40.sp,
                                      color: Colors.grey.shade400,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deviceData['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    deviceData['subtitle'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: widget.homeColor,
                                size: 28.sp,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: Colors.grey.shade400,
                                size: 28.sp,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Fixed Bottom Section - Watt TextField and Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10.r,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Watt Per Hour Input
                if (selectedDeviceId != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,0.h),
                    child: AppTextField(
                      controller: _deviceController,
                      label: 'Device Name',
                      hintText: 'Enter devie name',
                      showLabelOutside: true,
                      enabled: !isLoading,
                      keyboardType: TextInputType.text,
                     
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter power consumption';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (selectedDeviceId != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: AppTextField(
                      controller: _wattController,
                      label: 'Power Consumption',
                      hintText: 'Enter watt per hour',
                      showLabelOutside: true,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        Icons.flash_on,
                        color: widget.homeColor,
                        size: 20.sp,
                      ),
                      suffixIcon: AppText(text: 'Watt/Hr', color: Colors.grey.shade600, size: 14.sp),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter power consumption';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),

                // Add Button
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: selectedDeviceId == null || isLoading
                          ? null
                          : _addDeviceToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.homeColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Add Device',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDeviceToHome() async {
    if (selectedDeviceId == null) return;

    // Validate watt input
    if (_wattController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter power consumption (Watt Per Hour)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final wattPerHour = int.tryParse(_wattController.text.trim());
    if (wattPerHour == null || wattPerHour <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid positive number for watts'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get selected device data
      final deviceDoc = await _firestore
          .collection('Equipments')
          .doc(selectedDeviceId)
          .get();

      if (!deviceDoc.exists) {
        throw Exception('Device not found');
      }

      final deviceData = deviceDoc.data() as Map<String, dynamic>;

      // Add device to home's equipments subcollection
      await _firestore
          .collection('Homes')
          .doc(widget.homeId)
          .collection('Equipments')
          .add({
        'name': _deviceController.text,
        'subtitle': deviceData['subtitle'],
        'image': deviceData['image'],
        'wattPerHour': wattPerHour,
        'isOn': false,
        'lastOn': null,
        'totalSecondsUsed': 0,
        'totalWattsUsed': 0.0,
        'totalCost': 0.0,
        'iconCode': Icons.power.codePoint,
        'equipmentId': selectedDeviceId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding device: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
