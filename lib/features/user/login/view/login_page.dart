// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/features/user/model/user_model.dart';
import 'package:voltcare/features/widgets/appbutton.dart';
import 'package:voltcare/features/widgets/apptext.dart';
import 'package:voltcare/features/widgets/apptextfeild.dart';
import 'package:voltcare/utils/constants/app_colors.dart';
import 'package:voltcare/utils/constants/app_dimensions.dart';
import 'package:voltcare/utils/dynamic/appvariables.dart';
import 'package:voltcare/utils/helper/helper_pagenavigator.dart';
import 'package:voltcare/utils/sharedpref.dart';
import '../../../../utils/helper/helper_validator.dart';
import '../../../admin/home/view/home_screen.dart';
import '../../bottom_nav.dart';
import '../../signup/view/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist
        await FirebaseAuth.instance.signOut();
        _showSnackBar("Account not found. Please contact support.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get status from user document
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      UserModel userdata = UserModel.fromJson(userData);
      Appvariables.loggedInUser = userdata;
      if (userdata.status == -1) {
        // Account not found or invalid
        await FirebaseAuth.instance.signOut();
        _showSnackBar("Account not found. Please Register First.");
      } else if (userdata.status == 0) {
        // Account blocked
        await FirebaseAuth.instance.signOut();
        _showSnackBar("Your account has been blocked. Please contact support.");
      } else if (userdata.status == 1) {
        // Account active - save UID and proceed


        await SharedPref.save(key:  'uid', value:  userCredential.user!.uid);

        _showSnackBar("Login successful! Welcome back.");

        if (userdata.role == 'admin') {
          Screen.openAsNewPage(context, const AdminHomeScreen());
        } else {
          Screen.openAsNewPage(context, const BottomNavPage());
        }
      } else {
        // Unknown status
        await FirebaseAuth.instance.signOut();
        _showSnackBar("Account status unknown. Please contact support.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed.";

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many attempts. Please try again later.";
          break;
        default:
          errorMessage = "Login failed. ${e.message}";
      }

      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("An error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 40.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        AppText(
                          text: "Welcome Back 👋",
                          size: 30.sp,
                          weight: FontWeight.w700,
                        ),
                        SizedBox(height: 10.h),

                        AppText(
                          text: "Login to your account",
                          color: AppColors.textextralightcolor,
                        ),
                        SizedBox(height: 40.h),

                        // Email field
                        AppTextField(
                          controller: emailController,
                          fillColor: Colors.grey[100],
                          borderStyle: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: const BorderSide(
                              color: AppColors.transparent,
                            ),
                          ),
                          hintText: "ex: example@gmail.com",
                          label: 'Email',
                          validator: (value) {
                            return AppValidators.emailValidator(value);
                          },
                        ),

                        AppDimensions.gapLarge,

                        // Password field
                        AppTextField(
                          controller: passwordController,
                          fillColor: Colors.grey[100],
                          borderStyle: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: const BorderSide(
                              color: AppColors.transparent,
                            ),
                          ),
                          label: "Password",
                          hintText: '********',
                          isObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Login button
                        AppButton(
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _handleLogin,
                          text: "Login",
                        ),

                        SizedBox(height: 25.h),

                        // Sign Up text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignupPage(),
                                        ),
                                      );
                                    },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: isLoading ? Colors.grey : Colors.blue,
                                  fontWeight: FontWeight.bold,
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
            ),
          );
        },
      ),
    );
  }
}
