import '../../../core/user_context.dart';
import '../domain/maintenance_record.dart';

abstract interface class MaintenanceRepository {
  Future<MaintenanceRecord?> getRecord({
    required String id,
    String userId = mockUserId,
  });

  Future<List<MaintenanceRecord>> getRecordsForVehicle({
    required String vehicleId,
    String userId = mockUserId,
  });

  Future<void> saveRecord(MaintenanceRecord record);
}
