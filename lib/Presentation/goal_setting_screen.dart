import 'package:flutter/material.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  double _targetDistance = 5.0; // default distance in km

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Your Fitness Goal"),
        backgroundColor: const Color(0xFF00E676),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Target Distance (km)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Slider to select distance
            Slider(
              min: 1,
              max: 50,
              divisions: 49,
              value: _targetDistance,
              label: "${_targetDistance.toStringAsFixed(1)} km",
              activeColor: const Color(0xFF00E676),
              onChanged: (value) {
                setState(() {
                  _targetDistance = value;
                });
              },
            ),

            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // TODO: Save the goal to user's profile or local storage
                  Navigator.pop(context);
                },
                child: Text(
                  "Set Goal: ${_targetDistance.toStringAsFixed(1)} km",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
