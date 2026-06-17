import 'package:flutter/material.dart';
import 'package:tuition_app/services/class_service.dart';

class AddClassViewModel extends ChangeNotifier {
  final classNameController = TextEditingController();
  final sectionController = TextEditingController();

  final ClassService _classService;

  bool _isLoading = false;

  AddClassViewModel({
    ClassService? classService,
  }) : _classService = classService ?? ClassService();

  bool get isLoading => _isLoading;

  Future<void> createClass() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _classService.createClass(
        className: classNameController.text.trim(),
        section: sectionController.text.trim(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    classNameController.dispose();
    sectionController.dispose();
    super.dispose();
  }
}