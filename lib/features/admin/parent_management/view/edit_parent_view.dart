import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuition_app/features/admin/class_management/models/class_option.dart';
import 'package:tuition_app/services/class_service.dart';
import 'package:tuition_app/services/user_service.dart';

class EditParentView extends StatefulWidget {
  const EditParentView({
    super.key,
    required this.parentId,
    required this.initialName,
    required this.initialEmail,
    required this.initialClassId,
  });

  final String parentId;
  final String initialName;
  final String initialEmail;
  final String? initialClassId;

  @override
  State<EditParentView> createState() => _EditParentViewState();
}

class _EditParentViewState extends State<EditParentView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final ClassService _classService = ClassService();
  final UserService _userService = UserService();
  ClassOption? _selectedClass;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveParent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final selectedClass = _selectedClass;

    if (name.isEmpty) {
      throw Exception("Parent name is required");
    }

    if (email.isEmpty) {
      throw Exception("Email is required");
    }

    if (selectedClass == null) {
      throw Exception("Select a class");
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updateParent(
        userId: widget.parentId,
        name: name,
        email: email,
        classId: selectedClass.id,
        className: selectedClass.className,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Parent")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Parent Name"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _classService.getClasses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text("Unable to load classes");
                }

                final classes =
                    snapshot.data?.docs.map(ClassOption.fromDoc).toList() ?? [];

                if (classes.isEmpty) {
                  return const Text(
                    "Please create class first",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                if (_selectedClass == null && widget.initialClassId != null) {
                  for (final classOption in classes) {
                    if (classOption.id == widget.initialClassId) {
                      _selectedClass = classOption;
                      break;
                    }
                  }
                }

                return DropdownButtonFormField<ClassOption>(
                  value: _selectedClass,
                  decoration: const InputDecoration(labelText: "Assign Class"),
                  items: classes.map((classOption) {
                    return DropdownMenuItem<ClassOption>(
                      value: classOption,
                      child: Text(classOption.displayName),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (classOption) {
                          setState(() => _selectedClass = classOption);
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
                          await _saveParent();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Parent updated successfully"),
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
                    : const Text("Update Parent"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
