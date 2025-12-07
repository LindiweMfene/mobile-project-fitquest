import 'package:connectivity_plus/connectivity_plus.dart';
import '../Data/run_local_db.dart';
import '../Data/run_firestore.dart';

class RunSyncService {
  static Future<void> sync() async {
    final conn = await Connectivity().checkConnectivity();

    if (conn == ConnectivityResult.none) return; // offline

    final unsyncedRuns = await RunLocalDB.getUnsyncedRuns();

    for (final run in unsyncedRuns) {
      try {
        await RunFirestoreService.uploadRun(run);
        await RunLocalDB.markAsSynced(run.id);
      } catch (e) {
        print("Sync failed for ${run.id}");
      }
    }
  }
}
