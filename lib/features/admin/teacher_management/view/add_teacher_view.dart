import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/teacher_management/view_model/add_teacher_view_model.dart';

class AddTeacherView extends StatelessWidget {
  const AddTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTeacherViewModel(),
      child: Consumer<AddTeacherViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: const Text("Add Teacher")),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: vm.nameController,
                    decoration: const InputDecoration(
                      labelText: "Teacher Name",
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: vm.emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: vm.passwordController,
                    obscureText: !vm.isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          vm.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              try {
                                await vm.createTeacher();

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Teacher created successfully",
                                    ),
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
                      child: vm.isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Create Teacher"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
