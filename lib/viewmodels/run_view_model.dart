import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_project_fitquest/models/run_data.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/run_repo.dart';

class RunViewModel extends ChangeNotifier {
  final RunRepository _repository;

  RunViewModel(this._repository);

  final List<LatLng> _route = [];
  double _distance = 0.0;
  late DateTime _startTime;
  bool _isRunning = false;
  double _targetDistance = 0.0;
  StreamSubscription<Position>? _positionStream;

  bool _isInitializing = true;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  List<LatLng> get route => _route;
  double get distance => _distance;
  DateTime get startTime => _startTime;
  bool get isRunning => _isRunning;
  bool get isInitializing => _isInitializing;
  Duration get elapsed => _elapsed;

  String get formattedTime {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  String get distanceKm => (_distance / 1000).toStringAsFixed(2);

  String get formattedPace {
    if (_distance == 0 || _elapsed.inSeconds == 0) return "--:--";
    final km = _distance / 1000;
    final minutes = _elapsed.inSeconds / 60;
    final paceMinPerKm = minutes / km;
    final paceMin = paceMinPerKm.floor();
    final paceSec = ((paceMinPerKm - paceMin) * 60).round();
    return "${paceMin.toString().padLeft(2, '0')}:${paceSec.toString().padLeft(2, '0')}";
  }

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      await requestLocationPermission();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("Initialization error: $e");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      throw Exception("Location permission denied");
    }
  }

  void startRun({required double targetDistance}) {
    _route.clear();
    _distance = 0.0;
    _targetDistance = targetDistance;
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
    _isRunning = true;

    _startTimer();
    notifyListeners();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            LatLng newPoint = LatLng(position.latitude, position.longitude);

            if (_route.isNotEmpty) {
              _distance += _calculateDistance(_route.last, newPoint);
            }

            _route.add(newPoint);
            notifyListeners();

            if (_targetDistance > 0 && _distance >= _targetDistance) {
              pauseRun();
            }
          },
        );
  }

  void pauseRun() {
    _timer?.cancel();
    _positionStream?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resumeRun() {
    if (_route.isEmpty) {
      startRun(targetDistance: _targetDistance);
      return;
    }

    _isRunning = true;
    _startTimer();
    notifyListeners();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            LatLng newPoint = LatLng(position.latitude, position.longitude);

            if (_route.isNotEmpty) {
              _distance += _calculateDistance(_route.last, newPoint);
            }

            _route.add(newPoint);
            notifyListeners();

            if (_targetDistance > 0 && _distance >= _targetDistance) {
              pauseRun();
            }
          },
        );
  }

  void stopRun() {
    _timer?.cancel();
    _positionStream?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  Future<bool> finishRun() async {
    _timer?.cancel();
    _positionStream?.cancel();
    _isRunning = false;
    notifyListeners();

    if (_route.isEmpty) {
      debugPrint("No route data to save");
      return false;
    }

    try {
      final runData = getRunData();
      await _repository.saveRun(runData);
      debugPrint("Run saved successfully");
      return true;
    } catch (e) {
      debugPrint("Error saving run: $e");
      return false;
    }
  }

  Future<List<RunData>> getAllRuns() async {
    try {
      return await _repository.getRuns();
    } catch (e) {
      debugPrint("Error fetching runs: $e");
      return [];
    }
  }

  Future<RunData?> getRunById(String id) async {
    try {
      return await _repository.getRunById(id);
    } catch (e) {
      debugPrint("Error fetching run: $e");
      return null;
    }
  }

  Future<bool> deleteRun(String id) async {
    try {
      await _repository.deleteRun(id);
      debugPrint("Run deleted successfully");
      return true;
    } catch (e) {
      debugPrint("Error deleting run: $e");
      return false;
    }
  }

  Future<bool> updateRun(RunData run) async {
    try {
      await _repository.updateRun(run);
      debugPrint("Run updated successfully");
      return true;
    } catch (e) {
      debugPrint("Error updating run: $e");
      return false;
    }
  }

  Future<List<RunData>> getUnsyncedRuns() async {
    try {
      return await _repository.getUnsyncedRuns();
    } catch (e) {
      debugPrint("Error fetching unsynced runs: $e");
      return [];
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  RunData getRunData() {
    return RunData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      distance: _distance,
      route: _route,
      timestamp: _startTime,
      endTime: DateTime.now(),
      targetDistance: _targetDistance,
      duration: _elapsed,
      synced: 0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
