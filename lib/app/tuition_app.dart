import 'package:flutter/material.dart';

import 'package:tuition_app/core/constants/app_colors.dart';
import 'package:tuition_app/features/login/views/login_view.dart';

class TuitionApp extends StatelessWidget {
  const TuitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
