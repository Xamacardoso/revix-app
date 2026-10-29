import 'package:sqflite/sqflite.dart';

import '../../../data/local/app_database.dart';
import '../../vehicle_management/data/sqlite_vehicle_repository.dart';
import '../domain/maintenance_record.dart';
import 'sqlite_maintenance_repository.dart';

class OdometerUpdateConfirmationRequired implements Exception {
  const OdometerUpdateConfirmationRequired(this.current, this.service);

  final int current;
  final int service;
}

typedef MaintenanceEntryDatabaseProvider = Future<Database> Function();

abstract interface class MaintenanceRecordSaver {
  Future<void> save(
    MaintenanceRecord record, {
    bool confirmOdometerUpdate = false,
  });
}

class MaintenanceEntryService implements MaintenanceRecordSaver {
  MaintenanceEntryService({
    MaintenanceEntryDatabaseProvider? databaseProvider,
    SqliteVehicleRepository? vehicleRepository,
    SqliteMaintenanceRepository? maintenanceRepository,
  }) : _databaseProvider =
           databaseProvider ?? (() => AppDatabase.instance.database),
       _vehicleRepository = vehicleRepository ?? SqliteVehicleRepository(),
       _maintenanceRepository =
           maintenanceRepository ?? SqliteMaintenanceRepository();

  final MaintenanceEntryDatabaseProvider _databaseProvider;
  final SqliteVehicleRepository _vehicleRepository;
  final SqliteMaintenanceRepository _maintenanceRepository;

  @override
  Future<void> save(
    MaintenanceRecord record, {
    bool confirmOdometerUpdate = false,
  }) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final vehicles = await transaction.query(
        'vehicles',
        columns: ['current_odometer'],
        where: 'id = ? AND user_id = ?',
        whereArgs: [record.vehicleId, record.userId],
        limit: 1,
      );
      if (vehicles.isEmpty) {
        throw StateError('Vehicle not found for this user.');
      }
      final current = vehicles.single['current_odometer'] as int;
      final serviceOdometer = record.odometerAtService;
      if (serviceOdometer != null && serviceOdometer > current) {
        if (!confirmOdometerUpdate) {
          throw OdometerUpdateConfirmationRequired(current, serviceOdometer);
        }
        await _vehicleRepository.updateCurrentOdometerInExecutor(
          transaction,
          id: record.vehicleId,
          userId: record.userId,
          odometer: serviceOdometer,
        );
      }
      await _maintenanceRepository.saveRecordInExecutor(transaction, record);
    });
  }
}
