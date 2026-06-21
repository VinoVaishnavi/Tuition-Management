import 'package:flutter/material.dart';
import 'package:tuition_app/services/user_service.dart';

class EditTeacherView extends StatefulWidget {
  const EditTeacherView({
    super.key,
    required this.teacherId,
    required this.initialName,
    required this.initialEmail,
  });

  final String teacherId;
  final String initialName;
  final String initialEmail;

  @override
  State<EditTeacherView> createState() => _EditTeacherViewState();
}

class _EditTeacherViewState extends State<EditTeacherView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final UserService _userService = UserService();
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

  Future<void> _saveTeacher() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      throw Exception("Teacher name is required");
    }

    if (email.isEmpty) {
      throw Exception("Email is required");
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updateTeacher(
        userId: widget.teacherId,
        name: name,
        email: email,
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
      appBar: AppBar(title: const Text("Edit Teacher")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Teacher Name"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        try {
                          await _saveTeacher();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Teacher updated successfully"),
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
                    : const Text("Update Teacher"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
