import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/core/constants/app_colors.dart';
import 'package:tuition_app/features/admin/dashboard/view/admin_home_view.dart';
import 'package:tuition_app/features/admin/teacher_management/view/add_teacher_view.dart';
import 'package:tuition_app/features/admin/parent_management/view/add_parent_view.dart';
import 'package:tuition_app/features/admin/dashboard/view_model/admin_dashboard_view_model.dart';
import 'package:tuition_app/features/admin/dashboard/widgets/admin_bottom_navigation.dart';
import 'package:tuition_app/features/admin/parent_management/view/parent_list_view.dart';
import 'package:tuition_app/features/admin/teacher_management/view/teacher_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuition_app/features/login/views/login_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel(),
      child: Consumer<AdminDashboardViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(vm.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
            body: IndexedStack(
              index: vm.selectedIndex,
              children: const [
                AdminHomeView(),
                TeacherListView(),
                ParentListView(),
              ],
            ),
            floatingActionButton: vm.selectedTab == AdminDashboardTab.dashboard
                ? null
                : FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    onPressed: () {
                      final page = vm.selectedTab == AdminDashboardTab.teachers
                          ? const AddTeacherView()
                          : const AddParentView();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => page),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
            bottomNavigationBar: AdminBottomNavigation(
              currentIndex: vm.selectedIndex,
              onTap: vm.changeTab,
            ),
          );
        },
      ),
    );
  }
}
