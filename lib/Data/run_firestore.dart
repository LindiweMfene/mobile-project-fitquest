import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/run_data.dart';

class RunFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  static Future<void> uploadRun(RunData run) async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final data = run.toJson();
    data['timestamp'] = Timestamp.fromDate(run.timestamp);
    if (run.endTime != null) {
      data['endTime'] = Timestamp.fromDate(run.endTime!);
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .doc(run.id)
        .set(data, SetOptions(merge: true));
  }

  static Future<List<RunData>> getAllRuns() async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      if (data['timestamp'] is Timestamp) {
        data['timestamp'] = (data['timestamp'] as Timestamp)
            .toDate()
            .toIso8601String();
      }
      if (data['endTime'] is Timestamp) {
        data['endTime'] = (data['endTime'] as Timestamp)
            .toDate()
            .toIso8601String();
      }

      return RunData.fromJson(data);
    }).toList();
  }

  static Future<RunData?> getRunById(String runId) async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .doc(runId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    if (data['timestamp'] is Timestamp) {
      data['timestamp'] = (data['timestamp'] as Timestamp)
          .toDate()
          .toIso8601String();
    }
    if (data['endTime'] is Timestamp) {
      data['endTime'] = (data['endTime'] as Timestamp)
          .toDate()
          .toIso8601String();
    }

    return RunData.fromJson(data);
  }

  static Future<void> updateRun(RunData run) async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final data = run.toJson();
    data['timestamp'] = Timestamp.fromDate(run.timestamp);
    if (run.endTime != null) {
      data['endTime'] = Timestamp.fromDate(run.endTime!);
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .doc(run.id)
        .update(data);
  }

  static Future<void> deleteRun(String runId) async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .doc(runId)
        .delete();
  }

  static Future<void> deleteAllRuns() async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<Map<String, dynamic>> getRunStatistics() async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .get();

    int totalRuns = snapshot.docs.length;
    double totalDistance = 0.0;
    int totalDuration = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalDistance += (data['distance'] as num?)?.toDouble() ?? 0.0;
      totalDuration += (data['duration'] as int?) ?? 0;
    }

    return {
      'totalRuns': totalRuns,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'averageDistance': totalRuns > 0 ? totalDistance / totalRuns : 0.0,
      'averageDuration': totalRuns > 0 ? totalDuration / totalRuns : 0,
    };
  }

  static Future<List<RunData>> getRunsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      if (data['timestamp'] is Timestamp) {
        data['timestamp'] = (data['timestamp'] as Timestamp)
            .toDate()
            .toIso8601String();
      }
      if (data['endTime'] is Timestamp) {
        data['endTime'] = (data['endTime'] as Timestamp)
            .toDate()
            .toIso8601String();
      }

      return RunData.fromJson(data);
    }).toList();
  }

  static Stream<List<RunData>> watchRuns() {
    if (_userId == null) {
      throw Exception("No signed-in user found");
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('runs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            if (data['timestamp'] is Timestamp) {
              data['timestamp'] = (data['timestamp'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            if (data['endTime'] is Timestamp) {
              data['endTime'] = (data['endTime'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }

            return RunData.fromJson(data);
          }).toList();
        });
  }
}
