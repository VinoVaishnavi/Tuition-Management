import 'package:flutter/material.dart';
import 'package:tuition_app/services/user_service.dart';

class AddParentViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UserService _userService;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  AddParentViewModel({UserService? userService})
    : _userService = userService ?? UserService();

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> createParent() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.createUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: "parent",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
