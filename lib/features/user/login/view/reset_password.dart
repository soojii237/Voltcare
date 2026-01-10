import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 25.w, vertical: 60.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Reset Password",
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10.h),

              Text(
                "Enter your email and we'll send you a password reset link",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),

              SizedBox(height: 40.h),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email_outlined),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 18.h,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  onPressed: () {
                    // no logic as you requested
                  },
                  child: Text(
                    "Send Reset Link",
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              // Back to Login
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
