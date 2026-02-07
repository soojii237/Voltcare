// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/service/cloudinary_service.dart';
import 'package:voltcare/utils/dynamic/appvariables.dart';
import 'package:voltcare/utils/helper/helper_image_picker.dart';

import '../../../widgets/apptextfeild.dart';

class AddNewHomeScreen extends StatefulWidget {
  const AddNewHomeScreen({super.key});

  @override
  State<AddNewHomeScreen> createState() => _AddNewHomeScreenState();
}

class _AddNewHomeScreenState extends State<AddNewHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _chargePerWattController = TextEditingController();
  final _memberEmailController = TextEditingController();
  final _memberPasswordController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Color and Icon selection
  Color _selectedColor = const Color(0xFF6C63FF);
  IconData _selectedIcon = Icons.home;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined colors
  final List<Color> _availableColors = [
    const Color(0xFF6C63FF),
    const Color(0xFF232323),
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFFFF6F91),
    const Color(0xFF95E1D3),
    const Color(0xFFF38181),
    const Color(0xFFAA96DA),
    const Color(0xFFFCACA0),
    const Color(0xFFB8E994),
    const Color(0xFF78E08F),
  ];

  // Predefined icons with labels
  final List<Map<String, dynamic>> _availableIcons = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.house, 'label': 'House'},
    {'icon': Icons.apartment, 'label': 'Apartment'},
    {'icon': Icons.business, 'label': 'Office'},
    {'icon': Icons.cottage, 'label': 'Cottage'},
    {'icon': Icons.villa, 'label': 'Villa'},
    {'icon': Icons.holiday_village, 'label': 'Village'},
    {'icon': Icons.cabin, 'label': 'Cabin'},
    {'icon': Icons.store, 'label': 'Shop'},
    {'icon': Icons.storefront, 'label': 'Store'},
    {'icon': Icons.warehouse, 'label': 'Warehouse'},
    {'icon': Icons.factory, 'label': 'Factory'},
    {'icon': Icons.business_center, 'label': 'Business'},
    {'icon': Icons.home_work, 'label': 'Home Office'},
    {'icon': Icons.hotel, 'label': 'Hotel'},
    {'icon': Icons.meeting_room, 'label': 'Meeting Room'},
  ];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
              title: const Text('Camera'),
              onTap: () async {
                var data = await pickImage(context: context, isCamera: true);
                if (data['status'] == true && data['path'] != null) {
                  setState(() {
                    _selectedImage = File(data['path']);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(data['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF6C63FF),
              ),
              title: const Text('Gallery'),
              onTap: () async {
                var data = await pickImage(context: context, isCamera: false);
                if (data['status'] == true && data['path'] != null) {
                  setState(() {
                    _selectedImage = File(data['path']);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(data['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Background Color',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = color.value == _selectedColor.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showIconPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Icon',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = _availableIcons[index];
              final icon = iconData['icon'] as IconData;
              final label = iconData['label'] as String;
              final isSelected = icon == _selectedIcon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF).withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 32.sp,
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.grey[700],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  bool _isOfficeType() {
    final officeIcons = <IconData>[
      Icons.business,
      Icons.business_center,
      Icons.store,
      Icons.storefront,
      Icons.warehouse,
      Icons.factory,
      Icons.home_work,
      Icons.hotel,
      Icons.meeting_room,
    ];
    return officeIcons.contains(_selectedIcon);
  }

  Future<String?> _createLinkedAccount({
    required String email,
    required String password,
    required String name,
    required String role,
    required String memberType,
    required String homeId,
  }) async {
    final defaultApp = Firebase.app();
    final secondaryApp = await Firebase.initializeApp(
      name: 'secondary-${DateTime.now().millisecondsSinceEpoch}',
      options: defaultApp.options,
    );
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null) {
        return null;
      }

      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'uid': uid,
        'name': name,
        'namefilter': [
          for (int i = 1; i <= name.length; i++)
            name.substring(0, i).toLowerCase(),
        ],
        'email': email,
        'role': role,
        'memberType': memberType,
        'homeId': homeId,
        'address': '',
        'phone': '',
        'password': password,
        'status': 1,
        'createdAt': DateTime.now(),
      });

      return uid;
    } on FirebaseAuthException {
      return null;
    } catch (_) {
      return null;
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a home image'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        var imageUrl = await CloudneryUploader().uploadFile(
          XFile(_selectedImage!.path),
        );

        // Convert Color to hex string for Firestore
        String colorHex =
            '0x${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

        // Convert IconData to codePoint for Firestore
        int iconCodePoint = _selectedIcon.codePoint;
        bool isOffice = _isOfficeType();

        final homeDocRef = _firestore.collection('Homes').doc();

        // Prepare home data
        final Map<String, dynamic> homeData = {
          'homeId': homeDocRef.id,
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'imageUrl': imageUrl,
          'backgroundColor': colorHex,
          'iconCodePoint': iconCodePoint,
          'chargePerWatt':
              double.tryParse(_chargePerWattController.text.trim()) ?? 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 1,
          'userId': Appvariables.loggedInUser?.uid,
          'type': isOffice ? 'office' : 'home',
          'dailyTotals': {},
          'monthlyTotals': {},
        };

        // Save to Cloud Firestore
        await homeDocRef.set(homeData);

        String baseName = _nameController.text.trim();
        String email = _memberEmailController.text.trim();
        String password = _memberPasswordController.text.trim();
        String displayName = isOffice ? '$baseName Staff' : '$baseName Parent';
        String memberType = isOffice ? 'staff' : 'parent';

        String? linkedUid = await _createLinkedAccount(
          email: email,
          password: password,
          name: displayName,
          role: 'user',
          memberType: memberType,
          homeId: homeDocRef.id,
        );

        if (linkedUid == null) {
          throw Exception('Failed to create linked account');
        }

        await homeDocRef.update({
          isOffice ? 'staffUid' : 'parentUid': linkedUid,
          isOffice ? 'staffEmail' : 'parentEmail': email,
          isOffice ? 'staffPassword' : 'parentPassword': password,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isOffice ? 'Office' : 'Home'} "${_nameController.text}" added successfully!',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Clear form
          _nameController.clear();
          _addressController.clear();
          _chargePerWattController.clear();
          _memberEmailController.clear();
          _memberPasswordController.clear();
          setState(() {
            _selectedImage = null;
            _selectedColor = const Color(0xFF6C63FF);
            _selectedIcon = Icons.home;
          });

          // Navigate back
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding home: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _chargePerWattController.dispose();
    _memberEmailController.dispose();
    _memberPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOffice = _isOfficeType();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Home',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Section
                    GestureDetector(
                      onTap: _isLoading ? null : _showImageSourceDialog,
                      child: Container(
                        height: 220.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 220.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10.h,
                                    right: 10.w,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF6C63FF),
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : _showImageSourceDialog,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        247,
                                        224,
                                        10,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate,
                                      size: 50.sp,
                                      color: const Color(0xFF6C63FF),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Add Home Image',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Tap to upload from camera or gallery',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Color and Icon Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _showColorPickerDialog,
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      color: _selectedColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Background',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _showIconPickerDialog,
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6C63FF,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _selectedIcon,
                                      color: const Color(0xFF6C63FF),
                                      size: 28.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Icon',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Home Name Field using AppTextField
                    AppTextField(
                      controller: _nameController,
                      label: 'Home Name',
                      hintText: 'e.g., My Sweet Home',
                      showLabelOutside: true,
                      enabled: !_isLoading,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.home,
                          color: const Color(0xFF6C63FF),
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a home name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Address Field using AppTextField
                    AppTextField(
                      controller: _addressController,
                      label: 'Address',
                      hintText: 'Enter full address',
                      showLabelOutside: true,
                      enabled: !_isLoading,
                      maxLines: 3,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          bottom: 50.h,
                          left: 12.w,
                          right: 12.w,
                          top: 12.h,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: const Color(0xFF6C63FF),
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Charge Per Watt Field using AppTextField
                    AppTextField(
                      controller: _chargePerWattController,
                      label: 'Charge per kWh',
                      hintText: 'e.g., 0.15',
                      showLabelOutside: true,
                      enabled: !_isLoading,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.currency_rupee,
                          color: const Color(0xFF6C63FF),
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter charge per kWh';
                        }
                        final number = double.tryParse(value.trim());
                        if (number == null) {
                          return 'Please enter a valid number';
                        }
                        if (number < 0) {
                          return 'Charge cannot be negative';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    AppTextField(
                      controller: _memberEmailController,
                      label: '${isOffice ? 'Staff' : 'Parent'} Email',
                      hintText:
                          'Ex: ${isOffice ? 'staff' : 'parent'}@example.com',
                      showLabelOutside: true,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.email,
                          color: const Color(0xFF6C63FF),
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email';
                        }
                        final email = value.trim();
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    AppTextField(
                      controller: _memberPasswordController,
                      label: '${isOffice ? 'Staff' : 'Parent'} Password',
                      hintText: '********',
                      showLabelOutside: true,
                      enabled: !_isLoading,
                      isObscure: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.lock,
                          color: const Color(0xFF6C63FF),
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40.h),

                    // Add Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 24.sp),
                          SizedBox(width: 12.w),
                          Text(
                            'Add Home',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                      SizedBox(height: 16.h),
                      Text(
                        'Adding Home...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
