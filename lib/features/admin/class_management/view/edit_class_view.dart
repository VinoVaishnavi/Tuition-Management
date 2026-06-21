import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuition_app/features/admin/class_management/view_model/add_class_view_model.dart';
import 'package:tuition_app/services/class_service.dart';

class EditClassView extends StatefulWidget {
  const EditClassView({
    super.key,
    required this.classId,
    required this.initialClassName,
    required this.initialClassFees,
    required this.initialTeacherId,
  });

  final String classId;
  final String initialClassName;
  final double initialClassFees;
  final String? initialTeacherId;

  @override
  State<EditClassView> createState() => _EditClassViewState();
}

class _EditClassViewState extends State<EditClassView> {
  late final TextEditingController _classNameController;
  late final TextEditingController _feesController;
  final ClassService _classService = ClassService();
  TeacherOption? _selectedTeacher;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.initialClassName);
    _feesController = TextEditingController(
      text: _formatInitialFees(widget.initialClassFees),
    );
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    final className = _classNameController.text.trim();
    final classFees = double.tryParse(_feesController.text.trim());
    final selectedTeacher = _selectedTeacher;

    if (className.isEmpty) {
      throw Exception("Class name is required");
    }

    if (classFees == null || classFees <= 0) {
      throw Exception("Enter valid class fees");
    }

    setState(() => _isLoading = true);

    try {
      await _classService.updateClass(
        classId: widget.classId,
        className: className,
        classFees: classFees,
        teacherId: selectedTeacher?.id,
        teacherName: selectedTeacher?.name,
        teacherEmail: selectedTeacher?.email,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatInitialFees(double fees) {
    if (fees % 1 == 0) {
      return fees.toInt().toString();
    }

    return fees.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Class")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(labelText: "Class Name"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _feesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Class Fees",
                prefixText: "Rs. ",
              ),
            ),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _classService.getTeachers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text("Unable to load teachers");
                }

                final teachers =
                    snapshot.data?.docs.map(TeacherOption.fromDoc).toList() ??
                        [];

                if (_selectedTeacher == null &&
                    widget.initialTeacherId != null) {
                  for (final teacher in teachers) {
                    if (teacher.id == widget.initialTeacherId) {
                      _selectedTeacher = teacher;
                      break;
                    }
                  }
                }

                return DropdownButtonFormField<TeacherOption?>(
                  value: _selectedTeacher,
                  decoration: const InputDecoration(
                    labelText: "Assign Teacher (Optional)",
                  ),
                  items: [
                    const DropdownMenuItem<TeacherOption?>(
                      value: null,
                      child: Text("None"),
                    ),
                    ...teachers.map((teacher) {
                      return DropdownMenuItem<TeacherOption?>(
                        value: teacher,
                        child: Text(teacher.name),
                      );
                    }),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (teacher) {
                          setState(() => _selectedTeacher = teacher);
                        },
                );
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        try {
                          await _saveClass();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Class updated successfully"),
                            ),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Class"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
