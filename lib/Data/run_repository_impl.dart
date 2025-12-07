import 'package:mobile_project_fitquest/Data/run_firestore.dart';
import 'package:mobile_project_fitquest/Data/run_local_db.dart';
import 'package:mobile_project_fitquest/domain/run_repo.dart';
import 'package:mobile_project_fitquest/models/run_data.dart';

class RunRepositoryImpl implements RunRepository {
  @override
  Future<void> saveRun(RunData run) async {
    await RunLocalDB.insertRun(run);

    try {
      await RunFirestoreService.uploadRun(run);
    } catch (e) {
      // Log error but don't fail - will sync later
      print('Failed to upload to Firestore: $e');
    }
  }

  @override
  Future<List<RunData>> getRuns() async {
    return await RunLocalDB.getAllRuns();
  }

  @override
  Future<RunData?> getRunById(String id) async {
    return await RunLocalDB.getRunById(id);
  }

  @override
  Future<void> deleteRun(String id) async {
    await RunLocalDB.deleteRun(id);

    try {
      await RunFirestoreService.deleteRun(id);
    } catch (e) {
      print('Failed to delete from Firestore: $e');
    }
  }

  @override
  Future<void> updateRun(RunData run) async {
    await RunLocalDB.updateRun(run);

    try {
      await RunFirestoreService.uploadRun(run);
    } catch (e) {
      print('Failed to update Firestore: $e');
    }
  }

  @override
  Future<List<RunData>> getUnsyncedRuns() async {
    return await RunLocalDB.getUnsyncedRuns();
  }

  @override
  Future<void> markAsSynced(String id) async {
    await RunLocalDB.markAsSynced(id);
  }
}
