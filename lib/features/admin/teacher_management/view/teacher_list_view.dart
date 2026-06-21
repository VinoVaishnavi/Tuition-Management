import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/dashboard/view_model/admin_dashboard_view_model.dart';
import 'package:tuition_app/features/admin/dashboard/widgets/admin_list_card.dart';
import 'package:tuition_app/features/admin/teacher_management/view/edit_teacher_view.dart';
import 'package:tuition_app/services/user_service.dart';

class TeacherListView extends StatelessWidget {
  const TeacherListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminDashboardViewModel>();
    final userService = UserService();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: vm.usersByRole("teacher"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const AdminListStateMessage(
            icon: Icons.error_outline,
            message: "Unable to load teachers",
          );
        }

        final teachers = snapshot.data?.docs ?? [];

        if (teachers.isEmpty) {
          return const AdminListStateMessage(
            icon: Icons.school_outlined,
            message: "No teachers added yet",
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final teacherDoc = teachers[index];
            final teacherId = teacherDoc.id;
            final teacher = teacherDoc.data();
            final name = teacher["name"]?.toString() ?? "No name";
            final email = teacher["email"]?.toString() ?? "No email";

            return AdminListCard(
              icon: Icons.school_outlined,
              title: name,
              subtitle: email,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTeacherView(
                      teacherId: teacherId,
                      initialName: name,
                      initialEmail: email,
                    ),
                  ),
                );
              },
              onDelete: () async {
                final shouldDelete = await _confirmDelete(
                  context,
                  title: "Delete Teacher",
                  message: "Are you sure you want to delete this teacher?",
                );

                if (!shouldDelete) return;

                try {
                  await userService.deleteUser(
                    userId: teacherId,
                    role: "teacher",
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Teacher deleted successfully"),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
