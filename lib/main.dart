import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12 Pro Max base
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bias Deutsches Wörterbuch',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.black,
            secondary: Color(0xFFFFD700), // amarelo sutil
            onPrimary: Colors.white,
            onSecondary: Colors.black,
          ),
          textTheme: GoogleFonts.dancingScriptTextTheme().copyWith(
            bodyLarge: GoogleFonts.lato(),
            bodyMedium: GoogleFonts.lato(),
            bodySmall: GoogleFonts.lato(),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            titleTextStyle: GoogleFonts.dancingScript(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28.sp,
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const HomeScreen(),
      ),
    );
  }
} 