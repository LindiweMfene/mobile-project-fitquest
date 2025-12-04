import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;

class SignInScreenWrapper extends StatelessWidget {
  const SignInScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            // User not signed in → show Firebase UI login
            return ui.SignInScreen(
              providers: [
                ui.EmailAuthProvider(),
                // Optionally: GoogleAuthProvider()
              ],
            );
          } else {
            // User signed in → show home page
            return const HomeScreen();
          }
        }
        // Loading
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = auth.FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitQuest Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user.email}!'),
      ),
    );
  }
}
