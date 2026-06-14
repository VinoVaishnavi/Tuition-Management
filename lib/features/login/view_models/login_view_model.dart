import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    await Future.delayed(const Duration(seconds: 2));

    isLoading = false;
    notifyListeners();

    return email == "admin@gmail.com" && password == "123456";
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
