import 'package:cloud_firestore/cloud_firestore.dart';

class ClassOption {
  final String id;
  final String className;

  const ClassOption({
    required this.id,
    required this.className,
  });

  factory ClassOption.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return ClassOption(
      id: doc.id,
      className: data["className"]?.toString() ?? "No Class",
    );
  }

  String get displayName => className;

  @override
  bool operator ==(Object other) {
    return other is ClassOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
