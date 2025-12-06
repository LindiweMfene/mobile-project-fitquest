import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project_fitquest/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? errorMessage;
  bool isLoading = false;

  Future<UserModel?> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (name.isEmpty) {
      // name of user(username)
      errorMessage = "Username cannot be empty";
      notifyListeners();
      return null;
    }
    // Basic validation
    if (email.isEmpty || !email.contains('@')) {
      errorMessage = 'Please enter a valid email address.';
      notifyListeners();
      return null;
    }

    if (password.isEmpty || password.length < 6) {
      errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return null;
    }

    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'uid': credential.user!.uid,
      });
      final user = credential.user;
      if (user != null) {
        return UserModel(uid: user.uid, email: user.email ?? '', name: name);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
