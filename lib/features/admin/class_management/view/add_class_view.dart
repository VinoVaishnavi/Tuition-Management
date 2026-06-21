import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuition_app/features/admin/class_management/view_model/add_class_view_model.dart';

class AddClassView extends StatelessWidget {
  const AddClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddClassViewModel(),
      child: Consumer<AddClassViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Add Class"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: vm.classNameController,
                    decoration: const InputDecoration(
                      labelText: "Class Name",
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: vm.feesController,
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
                    stream: vm.teachersStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text("Unable to load teachers");
                      }

                      final teachers = snapshot.data?.docs
                              .map(TeacherOption.fromDoc)
                              .toList() ??
                          [];

                      return DropdownButtonFormField<TeacherOption?>(
                        value: vm.selectedTeacher,
                        decoration: const InputDecoration(
                          labelText: "Assign Teacher (Optional)",
                        ),
                        items: [
                          const DropdownMenuItem<TeacherOption?>(
                            value: null,
                            child: Text("Select Teacher"),
                          ),
                          ...teachers.map((teacher) {
                            return DropdownMenuItem<TeacherOption?>(
                              value: teacher,
                              child: Text(teacher.name),
                            );
                          }),
                        ],
                        onChanged: vm.isLoading ? null : vm.selectTeacher,
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
                                await vm.createClass();

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Class created successfully",
                                    ),
                                  ),
                                );

                                Navigator.pop(context);
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                  ),
                                );
                              }
                            },
                      child: vm.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Create Class"),
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
