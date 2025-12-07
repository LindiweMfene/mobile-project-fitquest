import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project_fitquest/Data/run_repository_impl.dart';
import 'package:mobile_project_fitquest/viewmodels/run_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mobile_project_fitquest/Presentation/login_page_screen.dart';

import 'package:mobile_project_fitquest/viewmodels/signup_viewmodel.dart'; // ✅ Import here
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RunViewModel(RunRepositoryImpl()), // ✅ Use here
        ),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
      ],
      child: MaterialApp(
        title: 'FitQuest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
