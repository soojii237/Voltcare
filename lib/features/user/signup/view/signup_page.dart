import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/features/widgets/appbutton.dart';
import 'package:voltcare/features/widgets/apptextfeild.dart';
import 'package:voltcare/utils/constants/app_dimensions.dart';
import 'package:voltcare/utils/extension/space_ext.dart';
import 'package:voltcare/utils/helper/helper_snackbar.dart';
import 'package:voltcare/utils/helper/helper_validator.dart';

import '../../../../utils/constants/app_colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      addressController = TextEditingController(),
      phoneController = TextEditingController(),
      passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Check if user already exists in Firestore
      final existingUsers = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        // User exists - check their status
        final userData = existingUsers.docs.first;
        final userStatus = userData.data()['status'] ?? 0;

        if (userStatus == 1) {
          // User is already active
          if (mounted) {
            CustomSnackBar.show(
              context,
              message: 'Account already exists. Please login instead.',
              type: SnackBarType.error,
            );
          }
        } else {
          // User exists but status != 1, re-enable account
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userData.id)
              .update({'status': 1, 'updatedAt': DateTime.now()});

          if (mounted) {
            CustomSnackBar.show(
              context,
              message: 'Account reactivated successfully! Please login.',
              type: SnackBarType.success,
            );
            Navigator.pop(context);
          }
        }
      } else {
        // Create new user
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Store user data in Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user?.uid)
            .set({
              'uid': userCredential.user?.uid,
              'name': nameController.text.trim(),
              'namefilter': [
                for (int i = 1; i <= nameController.text.length; i++)
                  nameController.text.substring(0, i).toLowerCase(),
              ],
              'email': email,
              'role':'user',
              'address': addressController.text.trim(),
              'phone': phoneController.text.trim(),
              'password': passwordController.text.trim(),
              'status': 1,
              'createdAt': DateTime.now(),
            });

        if (mounted) {
          CustomSnackBar.show(
            context,
            message: '🎉 Account created successfully! Please login.',
            type: SnackBarType.success,
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please login.';
          break;
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please use a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: errorMessage,
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'An unexpected error occurred. Please try again.',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 50.h),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                40.hBox,
                Text(
                  "Create Account ✨",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Fill in your details to sign up",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 40.h),

                // Form Fields
                AppTextField(
                  controller: nameController,
                  fillColor: Colors.grey[100],
                  hintText: 'Ex: Samuel John',
                  borderStyle: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.transparent),
                  ),
                  label: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                AppDimensions.gap,

                AppTextField(
                  controller: emailController,
                  fillColor: Colors.grey[100],
                  hintText: 'Ex: example@gmail.com',
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  borderStyle: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.transparent),
                  ),
                  validator: (value) {
                    return AppValidators.emailValidator(value);
                  },
                ),
                AppDimensions.gap,

                AppTextField(
                  controller: addressController,
                  fillColor: Colors.grey[100],
                  hintText: 'Ex: 123 Main St, City',
                  label: 'Address',
                  borderStyle: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.transparent),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    if (value.length < 10) {
                      return 'Please enter a complete address';
                    }
                    return null;
                  },
                ),
                AppDimensions.gap,

                AppTextField(
                  controller: phoneController,
                  fillColor: Colors.grey[100],
                  hintText: 'Ex: +1234567890',
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  borderStyle: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.transparent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                AppDimensions.gap,

                AppTextField(
                  controller: passwordController,
                  fillColor: Colors.grey[100],
                  borderStyle: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.transparent),
                  ),
                  hintText: '********',
                  label: 'Password',
                  isObscure: true,
                  validator: (value) {
                    return AppValidators.passwordValidator(value);
                  },
                ),

                SizedBox(height: 30.h),

                // Sign Up Button
                AppButton(
                  isLoading: _isLoading,
                  text: "Sign Up",
                  onPressed: _isLoading ? null : _handleSignup,
                ),

                SizedBox(height: 25.h),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: _isLoading ? Colors.grey : Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
