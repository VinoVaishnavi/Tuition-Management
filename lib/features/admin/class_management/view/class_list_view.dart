import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuition_app/features/admin/class_management/view/edit_class_view.dart';
import 'package:tuition_app/features/admin/class_management/view_model/add_class_view_model.dart';
import 'package:tuition_app/features/admin/dashboard/widgets/admin_list_card.dart';
import 'package:tuition_app/services/class_service.dart';

class ClassListView extends StatefulWidget {
  const ClassListView({super.key});

  @override
  State<ClassListView> createState() => _ClassListViewState();
}

class _ClassListViewState extends State<ClassListView> {
  static const String _allTeachersFilter = "all";

  final ClassService _classService = ClassService();
  String _selectedTeacherId = _allTeachersFilter;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _classService.getTeachers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const AdminListStateMessage(
            icon: Icons.error_outline,
            message: "Unable to load teachers",
          );
        }

        final teachers =
            snapshot.data?.docs.map(TeacherOption.fromDoc).toList() ?? [];
        final selectedTeacherExists = _selectedTeacherId == _allTeachersFilter ||
            teachers.any((teacher) => teacher.id == _selectedTeacherId);
        final selectedTeacherId = selectedTeacherExists
            ? _selectedTeacherId
            : _allTeachersFilter;

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
                    "Teacher",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTeacherId,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: _allTeachersFilter,
                            child: Text("All Teachers"),
                          ),
                          ...teachers.map((teacher) {
                            return DropdownMenuItem<String>(
                              value: teacher.id,
                              child: Text(teacher.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTeacherId = value ?? _allTeachersFilter;
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

                  final classes = snapshot.data?.docs ?? [];
                  final filteredClasses = selectedTeacherId == _allTeachersFilter
                      ? classes
                      : classes.where((classDoc) {
                          final classData = classDoc.data();
                          return classData["teacherId"]?.toString() ==
                              selectedTeacherId;
                        }).toList();

                  if (classes.isEmpty) {
                    return const AdminListStateMessage(
                      icon: Icons.menu_book_outlined,
                      message: "No classes added yet",
                    );
                  }

                  if (filteredClasses.isEmpty) {
                    return const AdminListStateMessage(
                      icon: Icons.menu_book_outlined,
                      message: "No classes found for this teacher",
                    );
                  }

                  return _ClassCardsList(
                    classes: filteredClasses,
                    classService: _classService,
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

class _ClassCardsList extends StatelessWidget {
  const _ClassCardsList({
    required this.classes,
    required this.classService,
    required this.confirmDelete,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> classes;
  final ClassService classService;
  final Future<bool> Function(
    BuildContext context, {
    required String title,
    required String message,
  }) confirmDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final classDoc = classes[index];
        final classId = classDoc.id;
        final classData = classes[index].data();

        final className = classData["className"]?.toString() ?? "No Class";

        final classFees = _formatFees(classData["classFees"]);
        final classFeesValue = _parseFees(classData["classFees"]);
        final teacherName =
            classData["teacherName"]?.toString() ?? "No teacher assigned";
        final teacherId = classData["teacherId"]?.toString();

        return AdminListCard(
          icon: Icons.class_outlined,
          title: className,
          detailText: "Fees: $classFees | Teacher: $teacherName",
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditClassView(
                  classId: classId,
                  initialClassName: className,
                  initialClassFees: classFeesValue,
                  initialTeacherId: teacherId,
                ),
              ),
            );
          },
          onDelete: () async {
            final shouldDelete = await confirmDelete(
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
