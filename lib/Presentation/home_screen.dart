import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_project_fitquest/Presentation/login_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitQuest Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to FitQuest!')),
    );
  }
}
