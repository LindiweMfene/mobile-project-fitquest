import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunData {
  final String id;
  final double distance;
  final List<LatLng> route;
  final DateTime timestamp;
  final DateTime? endTime;
  final double targetDistance;
  final Duration? duration;
  final int synced;

  RunData({
    required this.id,
    required this.distance,
    required this.route,
    required this.timestamp,
    this.endTime,
    required this.targetDistance,
    this.duration,
    this.synced = 0,
  });

  double get paceMinPerKm {
    if (distance == 0 || duration == null || duration!.inSeconds == 0) {
      return 0.0;
    }
    final km = distance / 1000;
    final minutes = duration!.inSeconds / 60;
    return minutes / km;
  }

  String get formattedPace {
    if (paceMinPerKm == 0) return "--:--";
    final paceMin = paceMinPerKm.floor();
    final paceSec = ((paceMinPerKm - paceMin) * 60).round();
    return "${paceMin.toString().padLeft(2, '0')}:${paceSec.toString().padLeft(2, '0')}";
  }

  double get distanceKm => distance / 1000;

  String get formattedDistance => "${distanceKm.toStringAsFixed(2)} km";

  String get formattedDuration {
    if (duration == null) return "00:00";
    final minutes = duration!.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = duration!.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds";
  }

  String get formattedDurationLong {
    if (duration == null) return "00:00:00";
    final hours = duration!.inHours.toString().padLeft(2, '0');
    final minutes = duration!.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = duration!.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  double get averageSpeedKmh {
    if (duration == null || duration!.inSeconds == 0) return 0.0;
    final hours = duration!.inSeconds / 3600;
    return distanceKm / hours;
  }

  bool get isCompleted => endTime != null;

  List<Map<String, double>> get routeAsMap {
    return route.map((p) => {"lat": p.latitude, "lng": p.longitude}).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'distance': distance,
      'route': jsonEncode(routeAsMap),
      'timestamp': timestamp.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetDistance': targetDistance,
      'duration': duration?.inSeconds,
      'synced': synced,
    };
  }

  factory RunData.fromMap(Map<String, dynamic> map) {
    final routeList = (jsonDecode(map['route']) as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList();

    return RunData(
      id: map['id'],
      distance: map['distance'],
      route: routeList,
      timestamp: DateTime.parse(map['timestamp']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      targetDistance: map['targetDistance'],
      duration: map['duration'] != null
          ? Duration(seconds: map['duration'])
          : null,
      synced: map['synced'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance': distance,
      'route': routeAsMap,
      'timestamp': timestamp.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetDistance': targetDistance,
      'duration': duration?.inSeconds,
    };
  }

  factory RunData.fromJson(Map<String, dynamic> json) {
    final routeList = (json['route'] as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList();

    return RunData(
      id: json['id'],
      distance: json['distance'],
      route: routeList,
      timestamp: DateTime.parse(json['timestamp']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      targetDistance: json['targetDistance'],
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
      synced: 1,
    );
  }

  RunData copyWith({
    String? id,
    double? distance,
    List<LatLng>? route,
    DateTime? timestamp,
    DateTime? endTime,
    double? targetDistance,
    Duration? duration,
    int? synced,
  }) {
    return RunData(
      id: id ?? this.id,
      distance: distance ?? this.distance,
      route: route ?? this.route,
      timestamp: timestamp ?? this.timestamp,
      endTime: endTime ?? this.endTime,
      targetDistance: targetDistance ?? this.targetDistance,
      duration: duration ?? this.duration,
      synced: synced ?? this.synced,
    );
  }
}
