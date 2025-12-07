import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/run_view_model.dart';
import '../models/run_data.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedPeriod = 'Week';
  List<RunData> _runHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRunHistory();
  }

  Future<void> _loadRunHistory() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<RunViewModel>();
    final runs = await viewModel.getAllRuns();
    setState(() {
      _runHistory = runs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildPeriodButton('Week'),
                              _buildPeriodButton('Month'),
                              _buildPeriodButton('Year'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Total Distance",
                            (_runHistory.fold<double>(
                                      0.0,
                                      (sum, run) => sum + run.distance,
                                    ) /
                                    1000)
                                .toStringAsFixed(1),
                            "km",
                            Icons.route,
                            const Color(0xFF00E676),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "Total Runs",
                            _runHistory.length.toString(),
                            "runs",
                            Icons.directions_run,
                            const Color(0xFF00B0FF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Avg Pace",
                            _calculateAvgPace(),
                            "/km",
                            Icons.speed,
                            const Color(0xFFFF6B35),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "Total Time",
                            _calculateTotalTime(),
                            "",
                            Icons.timer,
                            const Color(0xFFAB47BC),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Run History Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Run History",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Filter or sort functionality
                          },
                          child: Row(
                            children: [
                              Text(
                                "Filter",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.filter_list,
                                color: Colors.white.withOpacity(0.6),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Run History List
                  Expanded(
                    child: _runHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_run,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No runs yet",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Start your first run to see history",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            itemCount: _runHistory.length,
                            itemBuilder: (context, index) {
                              final run = _runHistory[index];
                              final durationSeconds =
                                  run.duration?.inSeconds ?? 0;
                              final distanceKm = run.distance / 1000;

                              return _buildRunHistoryCard(
                                date: _formatDate(run.timestamp),
                                distance: distanceKm.toStringAsFixed(2),
                                duration: _formatDuration(durationSeconds),
                                pace: _formatPace(durationSeconds, distanceKm),
                                calories: _calculateCalories(
                                  distanceKm,
                                ).toString(),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunHistoryCard({
    required String date,
    required String distance,
    required String duration,
    required String pace,
    required String calories,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_run,
                      color: Color(0xFF00E676),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Morning Run",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRunStat(Icons.route, distance, "km"),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildRunStat(Icons.timer, duration, ""),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildRunStat(Icons.speed, pace, "/km"),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildRunStat(Icons.local_fire_department, calories, "kcal"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunStat(IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  String _formatPace(int durationSeconds, double distanceKm) {
    if (distanceKm == 0) return "0:00";
    final paceSeconds = durationSeconds / distanceKm;
    final minutes = paceSeconds ~/ 60;
    final seconds = (paceSeconds % 60).round();
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  int _calculateCalories(double distanceKm) {
    // Rough estimate: ~60 calories per km
    return (distanceKm * 60).round();
  }

  String _calculateAvgPace() {
    if (_runHistory.isEmpty) return "0:00";

    double avgPaceSeconds = 0;
    final totalPace = _runHistory.fold<double>(0.0, (sum, run) {
      final distanceKm = run.distance / 1000;
      final durationSeconds = run.duration?.inSeconds ?? 0;
      if (distanceKm > 0 && durationSeconds > 0) {
        return sum + (durationSeconds / distanceKm);
      }
      return sum;
    });
    avgPaceSeconds = totalPace / _runHistory.length;

    final avgPaceMin = (avgPaceSeconds ~/ 60);
    final avgPaceSec = (avgPaceSeconds % 60).round();
    return "$avgPaceMin:${avgPaceSec.toString().padLeft(2, '0')}";
  }

  String _calculateTotalTime() {
    final totalTimeSeconds = _runHistory.fold<int>(
      0,
      (sum, run) => sum + (run.duration?.inSeconds ?? 0),
    );
    final totalHours = totalTimeSeconds ~/ 3600;
    final totalMinutes = (totalTimeSeconds % 3600) ~/ 60;
    return "${totalHours}h ${totalMinutes}m";
  }
}
