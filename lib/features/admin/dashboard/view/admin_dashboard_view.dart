import 'package:flutter/material.dart';
import 'package:tuition_app/features/admin/teacher_management/view/add_teacher_view.dart';
import 'package:tuition_app/features/admin/parent_management/view/add_parent_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuition_app/features/login/views/login_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTeacherView()),
                  );
                },
                child: const Text("Add Teacher"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddParentView()),
                  );
                },
                child: const Text("Add Parent"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
