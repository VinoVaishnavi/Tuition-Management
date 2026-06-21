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
}
