import 'package:cloud_firestore/cloud_firestore.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createClass({
    required String className,
    required String section,
    required double classFees,
    required String teacherId,
    required String teacherName,
    required String teacherEmail,
  }) async {
    await _firestore.collection('classes').add({
      'className': className,
      'section': section,
      'classFees': classFees,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getClasses() {
    return _firestore.collection('classes').snapshots();
  }
}
