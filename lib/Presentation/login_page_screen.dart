import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login_view_model.dart';
import 'home_screen.dart';



class LoginScreen extends StatelessWidget {
  LoginScreen({
    super.key,
  });
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FitQuest Login"),)
      ,
      body: Padding(padding:  const EdgeInsets.all(16.0),
      child: Column(children: [TextField(controller: emailController,decoration: InputDecoration(labelText: "Email"),)
      ,const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),],),)

      
    );
  }
}