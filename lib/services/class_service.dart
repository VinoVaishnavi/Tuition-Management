import 'package:cloud_firestore/cloud_firestore.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createClass({
    required String className,
    required double classFees,
    required String teacherId,
    required String teacherName,
    required String teacherEmail,
  }) async {
    await _firestore.collection('classes').add({
      'className': className,
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getTeachers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots();
  }

  Future<void> updateClass({
    required String classId,
    required String className,
    required double classFees,
    required String teacherId,
    required String teacherName,
    required String teacherEmail,
  }) async {
    final batch = _firestore.batch();
    final classRef = _firestore.collection('classes').doc(classId);

    batch.update(classRef, {
      'className': className,
      'classFees': classFees,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final parents = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'parent')
        .where('classId', isEqualTo: classId)
        .get();

    for (final parent in parents.docs) {
      batch.update(parent.reference, {
        'className': className,
      });
    }

    await batch.commit();
  }

  Future<void> deleteClass(String classId) async {
    final batch = _firestore.batch();
    final classRef = _firestore.collection('classes').doc(classId);

    batch.delete(classRef);

    final parents = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'parent')
        .where('classId', isEqualTo: classId)
        .get();

    for (final parent in parents.docs) {
      batch.update(parent.reference, {
        'classId': FieldValue.delete(),
        'className': FieldValue.delete(),
        'section': FieldValue.delete(),
      });
    }

    await batch.commit();
  }
}
