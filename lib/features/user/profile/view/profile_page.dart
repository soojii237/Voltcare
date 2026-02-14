// ignore_for_file: use_build_context_synchronously

import 'package:voltcare/utils/constants/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/features/user/login/view/login_page.dart';
import 'package:voltcare/utils/helper/helper_pagenavigator.dart';

import '../../../../utils/dynamic/appvariables.dart';
import '../../../../utils/sharedpref.dart';
import 'edit_profilescreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ---------------- PROFILE IMAGE ----------------
            Center(
              child: CircleAvatar(
                radius: 55.r,
                backgroundColor: Colors.blue.shade100,
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundImage: NetworkImage(
                    'https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg',
                  ), // optional
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              Appvariables.loggedInUser?.name ?? 'N/A',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5.h),

            Text(
              Appvariables.loggedInUser?.email ?? 'N/A',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            SizedBox(height: 25.h),

            // ---------------- DETAILS CARD ----------------
            _infoCard(
              "Email",
              Appvariables.loggedInUser?.email ?? 'N/A',
              Icons.mail,
            ),
            _infoCard(
              "Address",
              Appvariables.loggedInUser?.address ?? 'N/A',
              Icons.location_on,
            ),

            SizedBox(height: 30.h),

            // ---------------- EDIT PROFILE BUTTON ----------------
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Navigate to edit profile page
            //     },
            //     style: ElevatedButton.styleFrom(
            //         padding:  EdgeInsets.symmetric(vertical: 14.h),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12.r),
            //         )),
            //     child:  Text(
            //       "Edit Profile",
            //       style: TextStyle(fontSize: 16.sp),
            //     ),
            //   ),
            // ),
            SizedBox(height: 15.h),

            // In ProfilePage, update the Edit Profile button section:
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to edit profile page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );

                  // Refresh the page if profile was updated
                  if (result == true) {
                    setState(
                      () {},
                    ); // This will rebuild the page with updated data
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            // ---------------- LOGOUT BUTTON ----------------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  SharedPref.clear();
                  Screen.openAsNewPage(context, LoginPage());
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REUSABLE CARD ----------------
  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.iconBlue, size: 30.sp),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
