import '../models/run_data.dart';

abstract class RunRepository {
  Future<void> saveRun(RunData run);
  Future<List<RunData>> getRuns();
  Future<RunData?> getRunById(String id); // ✅ needed
  Future<void> deleteRun(String id); // ✅ needed
  Future<void> updateRun(RunData run); // ✅ needed
  Future<List<RunData>> getUnsyncedRuns(); // ✅ needed
  Future<void> markAsSynced(String id);
}
