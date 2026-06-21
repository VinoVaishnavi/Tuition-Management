import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuition_app/features/admin/class_management/view/edit_class_view.dart';
import 'package:tuition_app/features/admin/dashboard/widgets/admin_list_card.dart';
import 'package:tuition_app/services/class_service.dart';

class ClassListView extends StatelessWidget {
  const ClassListView({super.key});

  @override
  Widget build(BuildContext context) {
    final classService = ClassService();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: classService.getClasses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const AdminListStateMessage(
            icon: Icons.error_outline,
            message: "Unable to load classes",
          );
        }

        final classes = snapshot.data?.docs ?? [];

        if (classes.isEmpty) {
          return const AdminListStateMessage(
            icon: Icons.menu_book_outlined,
            message: "No classes added yet",
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final classDoc = classes[index];
            final classId = classDoc.id;
            final classData = classes[index].data();

            final className =
                classData["className"]?.toString() ?? "No Class";

            final section =
                classData["section"]?.toString() ?? "No Section";
            final classFees = _formatFees(classData["classFees"]);
            final classFeesValue = _parseFees(classData["classFees"]);
            final teacherName =
                classData["teacherName"]?.toString() ?? "No teacher assigned";
            final teacherId = classData["teacherId"]?.toString();

            return AdminListCard(
              icon: Icons.class_outlined,
              title: className,
              subtitle: "Section $section",
              detailText: "Fees: $classFees | Teacher: $teacherName",
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditClassView(
                      classId: classId,
                      initialClassName: className,
                      initialSection: section,
                      initialClassFees: classFeesValue,
                      initialTeacherId: teacherId,
                    ),
                  ),
                );
              },
              onDelete: () async {
                final shouldDelete = await _confirmDelete(
                  context,
                  title: "Delete Class",
                  message: "Are you sure you want to delete this class?",
                );

                if (!shouldDelete) return;

                try {
                  await classService.deleteClass(classId);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Class deleted successfully")),
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

  String _formatFees(Object? value) {
    final fees = value is num ? value : num.tryParse(value?.toString() ?? "");
    if (fees == null) return "Not set";

    if (fees % 1 == 0) {
      return "Rs. ${fees.toInt()}";
    }

    return "Rs. ${fees.toStringAsFixed(2)}";
  }

  double _parseFees(Object? value) {
    final fees = value is num ? value : num.tryParse(value?.toString() ?? "");
    return fees?.toDouble() ?? 0;
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
