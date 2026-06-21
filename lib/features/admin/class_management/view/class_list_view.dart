import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
            final classData = classes[index].data();

            final className =
                classData["className"]?.toString() ?? "No Class";

            final section =
                classData["section"]?.toString() ?? "No Section";

            return AdminListCard(
              icon: Icons.class_outlined,
              title: className,
              subtitle: "Section $section",
            );
          },
        );
      },
    );
  }
}
