import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? classId,
    String? className,
    String? section,
  }) async {
    UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userData = {
      'name': name,
      'email': email,
      'role': role,
    };

    if (classId != null && className != null && section != null) {
      userData.addAll({
        'classId': classId,
        'className': className,
        'section': section,
      });
    }

    await _firestore.collection('users').doc(credential.user!.uid).set(userData);
  }

  Future<void> updateTeacher({
    required String userId,
    required String name,
    required String email,
  }) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);

    batch.update(userRef, {
      'name': name,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final classes = await _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: userId)
        .get();

    for (final classDoc in classes.docs) {
      batch.update(classDoc.reference, {
        'teacherName': name,
        'teacherEmail': email,
      });
    }

    await batch.commit();
  }

  Future<void> updateParent({
    required String userId,
    required String name,
    required String email,
    required String classId,
    required String className,
    required String section,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'name': name,
      'email': email,
      'classId': classId,
      'className': className,
      'section': section,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser({
    required String userId,
    required String role,
  }) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);

    batch.delete(userRef);

    if (role == 'teacher') {
      final classes = await _firestore
          .collection('classes')
          .where('teacherId', isEqualTo: userId)
          .get();

      for (final classDoc in classes.docs) {
        batch.update(classDoc.reference, {
          'teacherId': FieldValue.delete(),
          'teacherName': FieldValue.delete(),
          'teacherEmail': FieldValue.delete(),
        });
      }
    }

    await batch.commit();
  }
}
