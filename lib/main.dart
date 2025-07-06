import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding.dart';
import 'package:provider/provider.dart';
import 'providers/options_provider.dart';
import 'package:get/get.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OptionsProvider()),
      ],
      child: GetMaterialApp(
        home: OnBoardingScreen(), // or your main navigation widget
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
