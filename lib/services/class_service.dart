import 'package:cloud_firestore/cloud_firestore.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createClass({
    required String className,
    required String section,
  }) async {
    await _firestore.collection('classes').add({
      'className': className,
      'section': section,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getClasses() {
    return _firestore.collection('classes').snapshots();
  }
}