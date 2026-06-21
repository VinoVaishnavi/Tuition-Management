import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/dashboard/view_model/admin_dashboard_view_model.dart';
import 'package:tuition_app/features/admin/dashboard/widgets/admin_list_card.dart';
import 'package:tuition_app/features/admin/parent_management/view/edit_parent_view.dart';
import 'package:tuition_app/services/user_service.dart';

class ParentListView extends StatelessWidget {
  const ParentListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminDashboardViewModel>();
    final userService = UserService();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: vm.usersByRole("parent"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const AdminListStateMessage(
            icon: Icons.error_outline,
            message: "Unable to load parents",
          );
        }

        final parents = snapshot.data?.docs ?? [];

        if (parents.isEmpty) {
          return const AdminListStateMessage(
            icon: Icons.people_outline,
            message: "No parents added yet",
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: parents.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final parentDoc = parents[index];
            final parentId = parentDoc.id;
            final parent = parentDoc.data();
            final name = parent["name"]?.toString() ?? "No name";
            final email = parent["email"]?.toString() ?? "No email";
            final className =
                parent["className"]?.toString() ?? "No class assigned";
            final section = parent["section"]?.toString();
            final classText = section == null
                ? className
                : "$className - Section $section";

            return AdminListCard(
              icon: Icons.people_outline,
              title: name,
              subtitle: email,
              detailText: classText,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditParentView(
                      parentId: parentId,
                      initialName: name,
                      initialEmail: email,
                      initialClassId: parent["classId"]?.toString(),
                    ),
                  ),
                );
              },
              onDelete: () async {
                final shouldDelete = await _confirmDelete(
                  context,
                  title: "Delete Parent",
                  message: "Are you sure you want to delete this parent?",
                );

                if (!shouldDelete) return;

                try {
                  await userService.deleteUser(
                    userId: parentId,
                    role: "parent",
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Parent deleted successfully")),
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
