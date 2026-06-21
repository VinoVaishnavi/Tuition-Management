import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuition_app/services/class_service.dart';

class TeacherOption {
  const TeacherOption({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory TeacherOption.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return TeacherOption(
      id: doc.id,
      name: data["name"]?.toString() ?? "No name",
      email: data["email"]?.toString() ?? "No email",
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TeacherOption &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AddClassViewModel extends ChangeNotifier {
  final classNameController = TextEditingController();
  final sectionController = TextEditingController();
  final feesController = TextEditingController();

  final ClassService _classService;
  final FirebaseFirestore _firestore;

  bool _isLoading = false;
  TeacherOption? _selectedTeacher;

  AddClassViewModel({
    ClassService? classService,
    FirebaseFirestore? firestore,
  }) : _classService = classService ?? ClassService(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  bool get isLoading => _isLoading;
  TeacherOption? get selectedTeacher => _selectedTeacher;

  Stream<QuerySnapshot<Map<String, dynamic>>> get teachersStream {
    return _firestore
        .collection("users")
        .where("role", isEqualTo: "teacher")
        .snapshots();
  }

  void selectTeacher(TeacherOption? teacher) {
    _selectedTeacher = teacher;
    notifyListeners();
  }

  Future<void> createClass() async {
    final className = classNameController.text.trim();
    final section = sectionController.text.trim();
    final feesText = feesController.text.trim();
    final classFees = double.tryParse(feesText);
    final teacher = _selectedTeacher;

    if (className.isEmpty) {
      throw Exception("Class name is required");
    }

    if (section.isEmpty) {
      throw Exception("Section is required");
    }

    if (classFees == null || classFees <= 0) {
      throw Exception("Enter valid class fees");
    }

    if (teacher == null) {
      throw Exception("Please assign a teacher");
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _classService.createClass(
        className: className,
        section: section,
        classFees: classFees,
        teacherId: teacher.id,
        teacherName: teacher.name,
        teacherEmail: teacher.email,
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
    feesController.dispose();
    super.dispose();
  }
}
