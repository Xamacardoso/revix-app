import '../../../core/user_context.dart';
import '../domain/vehicle.dart';

abstract interface class VehicleRepository {
  Future<Vehicle?> getVehicle({required String id, String userId = mockUserId});

  Future<List<Vehicle>> getActiveVehicles({String userId = mockUserId});

  Future<List<Vehicle>> getArchivedVehicles({String userId = mockUserId});

  Future<void> saveVehicle(Vehicle vehicle);

  Future<void> updateCurrentOdometer({
    required String id,
    required int odometer,
    String userId = mockUserId,
  });

  Future<void> archiveVehicle({required String id, String userId = mockUserId});

  Future<void> restoreVehicle({required String id, String userId = mockUserId});
}
