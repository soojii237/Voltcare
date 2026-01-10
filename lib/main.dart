import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voltcare/utils/sharedpref.dart';

import 'features/user/splash/view/splash_page.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
const SystemUiOverlayStyle(
systemNavigationBarColor: Colors.transparent, // Transparent system navigation bar
statusBarColor: Colors.transparent, // Transparent status bar
),
);
  SharedPref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 804), 
      minTextAdapt: true,               
      splitScreenMode: true,           
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      child: SplashPage(), 
    );
  }
}
