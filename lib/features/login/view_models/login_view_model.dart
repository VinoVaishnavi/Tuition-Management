import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? role;

  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Please enter email and password";
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final signedInEmail =
          credential.user?.email?.trim().toLowerCase() ?? email;
      final userSnapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: signedInEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        await _auth.signOut();
        errorMessage = "User record not found";
        return false;
      }

      final userData = userSnapshot.docs.first.data();
      role = userData["role"]?.toString().trim().toLowerCase();

      if (role != "admin") {
        await _auth.signOut();
        errorMessage = "You do not have admin access";
        return false;
      }

      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = _authErrorMessage(error);
      return false;
    } on FirebaseException catch (error) {
      errorMessage = error.message ?? "Unable to load user details";
      return false;
    } catch (_) {
      errorMessage = "Something went wrong. Please try again";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case "invalid-email":
        return "Invalid email address";
      case "user-disabled":
        return "This account has been disabled";
      case "user-not-found":
      case "wrong-password":
      case "invalid-credential":
        return "Invalid email or password";
      default:
        return error.message ?? "Login failed. Please try again";
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
