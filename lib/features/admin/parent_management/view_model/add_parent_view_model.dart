import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuition_app/features/admin/class_management/models/class_option.dart';
import 'package:tuition_app/services/class_service.dart';
import 'package:tuition_app/services/user_service.dart';

class AddParentViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UserService _userService;
  final ClassService _classService;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  ClassOption? _selectedClass;

  AddParentViewModel({
    UserService? userService,
    ClassService? classService,
  })  : _userService = userService ?? UserService(),
        _classService = classService ?? ClassService();

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  ClassOption? get selectedClass => _selectedClass;

  Stream<QuerySnapshot<Map<String, dynamic>>> get classesStream {
    return _classService.getClasses();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void selectClass(ClassOption? classOption) {
    _selectedClass = classOption;
    notifyListeners();
  }

  Future<void> createParent() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final selectedClass = _selectedClass;

    if (name.isEmpty) {
      throw Exception("Parent name is required");
    }

    if (email.isEmpty) {
      throw Exception("Email is required");
    }

    if (password.isEmpty) {
      throw Exception("Password is required");
    }

    if (selectedClass == null) {
      throw Exception("Select a class");
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.createUser(
        name: name,
        email: email,
        password: password,
        role: "parent",
        classId: selectedClass.id,
        className: selectedClass.className,
        section: selectedClass.section,
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
