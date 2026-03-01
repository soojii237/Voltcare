import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voltcare/features/user/model/user_model.dart';
import 'package:voltcare/utils/dynamic/appvariables.dart';

import '../../../../utils/helper/helper_pagenavigator.dart';
import '../../../../utils/sharedpref.dart';
import '../../../admin/home/view/home_screen.dart';
import '../../bottom_nav.dart';
import '../../login/view/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // Check authentication after animation
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Get UID from SharedPreferences
      String? uid = await SharedPref.getstring('uid');

      if (uid == null || uid.isEmpty) {
        // No saved UID, navigate to login
        _navigateToLogin();
        return;
      }

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist
        await _handleInvalidAccount("Account not found. Please register first.");
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      int status = userData['status'] ?? -1;
      String role = userData['role'] ?? 'user';
      Appvariables.loggedInUser = UserModel.fromJson(userData);
      // Check user status
      if (status == -1) {
        // Account not found or invalid
        await _handleInvalidAccount("Account not found. Please register first.");
      } else if (status == 0) {
        // Account blocked
        await _handleInvalidAccount("Your account has been blocked. Please contact support.");
      } else if (status == 1) {
        // Account active - navigate based on role
        if (!mounted) return;
        
        if (role == 'admin') {
          Screen.openAsNewPage(context, const AdminHomeScreen());
        } else {
          Screen.openAsNewPage(context, const BottomNavPage());
        }
      } else {
        // Unknown status
        await _handleInvalidAccount("Account status unknown. Please contact support.");
      }
    } catch (e) {
      // Error occurred, navigate to login
      debugPrint("Error checking auth: $e");
      _navigateToLogin();
    }
  }

  Future<void> _handleInvalidAccount(String message) async {
    // Sign out and clear SharedPreferences
    await FirebaseAuth.instance.signOut();
    await SharedPref.remove(key: 'uid');
    
    if (!mounted) return;
    
    // Show message and navigate to login
    _showSnackBar(message);
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flash_on_rounded, color: Colors.white, size: 80.sp),
              SizedBox(height: 10.h),
              Text(
                "VOLTCARE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}