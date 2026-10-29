import 'package:sqflite/sqflite.dart';

import '../../../core/user_context.dart';
import '../../../data/local/app_database.dart';
import '../domain/vehicle.dart';
import 'vehicle_repository.dart';

typedef VehicleDatabaseProvider = Future<Database> Function();

class SqliteVehicleRepository implements VehicleRepository {
  SqliteVehicleRepository({VehicleDatabaseProvider? databaseProvider})
    : _databaseProvider =
          databaseProvider ?? (() => AppDatabase.instance.database);

  final VehicleDatabaseProvider _databaseProvider;

  @override
  Future<Vehicle?> getVehicle({
    required String id,
    String userId = mockUserId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      'vehicles',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    return rows.isEmpty ? null : Vehicle.fromMap(rows.single);
  }

  @override
  Future<List<Vehicle>> getActiveVehicles({String userId = mockUserId}) =>
      _getVehicles(userId: userId, archived: false);

  @override
  Future<List<Vehicle>> getArchivedVehicles({String userId = mockUserId}) =>
      _getVehicles(userId: userId, archived: true);

  Future<List<Vehicle>> _getVehicles({
    required String userId,
    required bool archived,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      'vehicles',
      where: archived
          ? 'user_id = ? AND archived_at IS NOT NULL'
          : 'user_id = ? AND archived_at IS NULL',
      whereArgs: [userId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Vehicle.fromMap).toList(growable: false);
  }

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {
    final database = await _databaseProvider();
    final existingRows = await database.query(
      'vehicles',
      columns: ['id'],
      where: 'id = ? AND user_id = ?',
      whereArgs: [vehicle.id, vehicle.userId],
      limit: 1,
    );
    final values = vehicle.toMap();

    if (existingRows.isEmpty) {
      await database.insert('vehicles', values);
      return;
    }

    values
      ..remove('created_at')
      ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await database.update(
      'vehicles',
      values,
      where: 'id = ? AND user_id = ?',
      whereArgs: [vehicle.id, vehicle.userId],
    );
  }

  @override
  Future<void> updateCurrentOdometer({
    required String id,
    required int odometer,
    String userId = mockUserId,
  }) async {
    final database = await _databaseProvider();
    await updateCurrentOdometerInExecutor(
      database,
      id: id,
      userId: userId,
      odometer: odometer,
    );
  }

  Future<void> updateCurrentOdometerInExecutor(
    DatabaseExecutor executor, {
    required String id,
    required int odometer,
    String userId = mockUserId,
  }) async {
    final updated = await executor.update(
      'vehicles',
      {
        'current_odometer': odometer,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    if (updated == 0) {
      throw StateError('Vehicle not found for this user.');
    }
  }

  @override
  Future<void> archiveVehicle({
    required String id,
    String userId = mockUserId,
  }) async {
    final database = await _databaseProvider();
    final now = DateTime.now().toUtc().toIso8601String();
    final updated = await database.update(
      'vehicles',
      {'archived_at': now, 'updated_at': now},
      where: 'id = ? AND user_id = ? AND archived_at IS NULL',
      whereArgs: [id, userId],
    );
    if (updated == 0) {
      throw StateError('Active vehicle not found for this user.');
    }
  }

  @override
  Future<void> restoreVehicle({
    required String id,
    String userId = mockUserId,
  }) async {
    final database = await _databaseProvider();
    final updated = await database.update(
      'vehicles',
      {
        'archived_at': null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ? AND user_id = ? AND archived_at IS NOT NULL',
      whereArgs: [id, userId],
    );
    if (updated == 0) {
      throw StateError('Archived vehicle not found for this user.');
    }
  }
}
