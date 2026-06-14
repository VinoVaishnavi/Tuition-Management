import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/dashboard/view_model/admin_dashboard_view_model.dart';

class TeacherListView extends StatelessWidget {
  const TeacherListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminDashboardViewModel>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: vm.usersByRole("teacher"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Unable to load teachers"));
        }

        final teachers = snapshot.data?.docs ?? [];

        if (teachers.isEmpty) {
          return const Center(child: Text("No teachers added yet"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final teacher = teachers[index].data();
            final name = teacher["name"]?.toString() ?? "No name";
            final email = teacher["email"]?.toString() ?? "No email";

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
              title: Text(name),
              subtitle: Text(email),
            );
          },
        );
      },
    );
  }
}
