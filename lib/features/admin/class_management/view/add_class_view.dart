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
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: vm.classNameController,
                    decoration: const InputDecoration(
                      labelText: "Class Name",
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: vm.sectionController,
                    decoration: const InputDecoration(
                      labelText: "Section",
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
                          ? const CircularProgressIndicator()
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