import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';


class LoginViewModel extends ChangeNotifier{
    final FirebaseAuth _auth = FirebaseAuth.instance; //reference to Firebase authentication service.
    String? errorMessage;//to store error messages during authentication processes.
    bool isLoading = false; //indicates if an authentication process is ongoing. ture if in progress, false otherwise.

    Future<UserModel?> login(String email, String password) async {
  // Basic validation
  if (email.isEmpty || !email.contains('@')) {
    errorMessage = 'Please enter a valid email address.';
    notifyListeners();
    return null;
  }

  if (password.isEmpty) {
    errorMessage = 'Password cannot be empty.';
    notifyListeners();
    return null;
  }

  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = credential.user;
    if (user != null) {
      return UserModel(uid: user.uid, email: user.email ?? ''); // if email is null, return empty string
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
