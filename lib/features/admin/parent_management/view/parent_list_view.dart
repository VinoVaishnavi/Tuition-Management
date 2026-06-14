import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/dashboard/view_model/admin_dashboard_view_model.dart';

class ParentListView extends StatelessWidget {
  const ParentListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminDashboardViewModel>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: vm.usersByRole("parent"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Unable to load parents"));
        }

        final parents = snapshot.data?.docs ?? [];

        if (parents.isEmpty) {
          return const Center(child: Text("No parents added yet"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: parents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final parent = parents[index].data();
            final name = parent["name"]?.toString() ?? "No name";
            final email = parent["email"]?.toString() ?? "No email";

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.people)),
              title: Text(name),
              subtitle: Text(email),
            );
          },
        );
      },
    );
  }
}
