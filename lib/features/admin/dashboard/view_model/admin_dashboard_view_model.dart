import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AdminDashboardTab { dashboard, classes, teachers, parents }

class AdminDashboardViewModel extends ChangeNotifier {
  AdminDashboardTab _selectedTab = AdminDashboardTab.dashboard;
  final FirebaseFirestore _firestore;

  AdminDashboardViewModel({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  AdminDashboardTab get selectedTab => _selectedTab;

  int get selectedIndex => AdminDashboardTab.values.indexOf(_selectedTab);

  String get title {
    switch (_selectedTab) {
      case AdminDashboardTab.dashboard:
        return "Dashboard";
      case AdminDashboardTab.classes:
        return "Class";
      case AdminDashboardTab.teachers:
        return "Teachers";
      case AdminDashboardTab.parents:
        return "Parents";
    }
  }

  void changeTab(int index) {
    final nextTab = AdminDashboardTab.values[index];
    if (_selectedTab == nextTab) return;

    _selectedTab = nextTab;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usersByRole(String role) {
    return _firestore
        .collection("users")
        .where("role", isEqualTo: role)
        .snapshots();
  }
}
