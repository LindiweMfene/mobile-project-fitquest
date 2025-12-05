import 'package:flutter/material.dart';
import 'package:mobile_project_fitquest/Presentation/signup.dart';
import 'package:mobile_project_fitquest/models/user_model.dart';
import 'package:mobile_project_fitquest/viewmodels/login_view_model.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text("FitQuest Login")),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'asset/images/fitnesslogin.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const SizedBox(height: 80), // Push down a bit
                          const Text(
                            "FitQuest",
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          // 🔹 Dark overlay for readability
                          Container(color: Colors.white),
                          const SizedBox(height: 90),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: const TextStyle(
                                color: Colors.white, // Label text color
                              ),
                              filled: true, // Makes background white
                              fillColor: const Color.fromARGB(255, 63, 60, 60),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(
                                color: Colors.white, // Label text color
                              ),

                              filled: true, // Makes background olor
                              fillColor: const Color.fromARGB(255, 63, 60, 60),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (viewModel.errorMessage != null)
                            Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          SizedBox(
                            width: double
                                .infinity, // Makes button full-width like text fields
                            height: 50, // Adjust height to your preference
                            child: ElevatedButton(
                              onPressed: () async {
                                UserModel? user = await viewModel.login(
                                  emailController.text,
                                  passwordController.text,
                                );
                                if (user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HomeScreen(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  121,
                                  61,
                                  249,
                                ),
                                foregroundColor: Colors.white, // Text color
                                elevation: 4, // Button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Match text field border radius
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18, // Make text larger
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SignupScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
