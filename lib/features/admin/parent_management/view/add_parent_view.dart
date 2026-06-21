import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/class_management/models/class_option.dart';
import 'package:tuition_app/features/admin/parent_management/view_model/add_parent_view_model.dart';

class AddParentView extends StatelessWidget {
  const AddParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddParentViewModel(),
      child: Consumer<AddParentViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: const Text("Add Parent")),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: vm.nameController,
                    decoration: const InputDecoration(labelText: "Parent Name"),
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

                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: vm.classesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text("Unable to load classes");
                      }

                      final classes = snapshot.data?.docs
                              .map(ClassOption.fromDoc)
                              .toList() ??
                          [];

                      if (classes.isEmpty) {
                        return const Text("No classes available");
                      }

                      return DropdownButtonFormField<ClassOption>(
                        value: vm.selectedClass,
                        decoration: const InputDecoration(
                          labelText: "Assign Class",
                        ),
                        items: classes.map((classOption) {
                          return DropdownMenuItem<ClassOption>(
                            value: classOption,
                            child: Text(classOption.displayName),
                          );
                        }).toList(),
                        onChanged: vm.isLoading ? null : vm.selectClass,
                      );
                    },
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
                                await vm.createParent();

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Parent created successfully"),
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
                          : const Text("Create Parent"),
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
