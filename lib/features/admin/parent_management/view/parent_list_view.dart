import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/class_management/models/class_option.dart';
import 'package:tuition_app/features/admin/dashboard/view_model/admin_dashboard_view_model.dart';
import 'package:tuition_app/features/admin/dashboard/widgets/admin_list_card.dart';
import 'package:tuition_app/features/admin/parent_management/view/edit_parent_view.dart';
import 'package:tuition_app/services/class_service.dart';
import 'package:tuition_app/services/user_service.dart';

class ParentListView extends StatefulWidget {
  const ParentListView({super.key});

  @override
  State<ParentListView> createState() => _ParentListViewState();
}

class _ParentListViewState extends State<ParentListView> {
  static const String _allClassesFilter = "all";

  final ClassService _classService = ClassService();
  final UserService _userService = UserService();
  String _selectedClassId = _allClassesFilter;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminDashboardViewModel>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _classService.getClasses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const AdminListStateMessage(
            icon: Icons.error_outline,
            message: "Unable to load classes",
          );
        }

        final classes =
            snapshot.data?.docs.map(ClassOption.fromDoc).toList() ?? [];
        final selectedClassExists = _selectedClassId == _allClassesFilter ||
            classes.any((classOption) => classOption.id == _selectedClassId);
        final selectedClassId = selectedClassExists
            ? _selectedClassId
            : _allClassesFilter;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Class",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedClassId,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: _allClassesFilter,
                            child: Text("All Classes"),
                          ),
                          ...classes.map((classOption) {
                            return DropdownMenuItem<String>(
                              value: classOption.id,
                              child: Text(classOption.displayName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedClassId = value ?? _allClassesFilter;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                  final filteredParents = selectedClassId == _allClassesFilter
                      ? parents
                      : parents.where((parentDoc) {
                          final parent = parentDoc.data();
                          return parent["classId"]?.toString() ==
                              selectedClassId;
                        }).toList();

                  if (parents.isEmpty) {
                    return const AdminListStateMessage(
                      icon: Icons.people_outline,
                      message: "No parents added yet",
                    );
                  }

                  if (filteredParents.isEmpty) {
                    return const AdminListStateMessage(
                      icon: Icons.people_outline,
                      message: "No parents found for this class",
                    );
                  }

                  return _ParentCardsList(
                    parents: filteredParents,
                    userService: _userService,
                    confirmDelete: _confirmDelete,
                  );
                },
              ),
            ),
          ],
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

class _ParentCardsList extends StatelessWidget {
  const _ParentCardsList({
    required this.parents,
    required this.userService,
    required this.confirmDelete,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> parents;
  final UserService userService;
  final Future<bool> Function(
    BuildContext context, {
    required String title,
    required String message,
  }) confirmDelete;

  @override
  Widget build(BuildContext context) {
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
            final shouldDelete = await confirmDelete(
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
  }
}
