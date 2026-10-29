import 'package:sqflite/sqflite.dart';

import '../../../core/user_context.dart';
import '../../../data/local/app_database.dart';
import '../domain/maintenance_record.dart';
import 'maintenance_repository.dart';

typedef MaintenanceDatabaseProvider = Future<Database> Function();

class SqliteMaintenanceRepository implements MaintenanceRepository {
  SqliteMaintenanceRepository({MaintenanceDatabaseProvider? databaseProvider})
    : _databaseProvider =
          databaseProvider ?? (() => AppDatabase.instance.database);

  final MaintenanceDatabaseProvider _databaseProvider;

  @override
  Future<MaintenanceRecord?> getRecord({
    required String id,
    String userId = mockUserId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      'maintenance_records',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    return rows.isEmpty ? null : MaintenanceRecord.fromMap(rows.single);
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsForVehicle({
    required String vehicleId,
    String userId = mockUserId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      'maintenance_records',
      where: 'vehicle_id = ? AND user_id = ?',
      whereArgs: [vehicleId, userId],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(MaintenanceRecord.fromMap).toList(growable: false);
  }

  @override
  Future<void> saveRecord(MaintenanceRecord record) async {
    final database = await _databaseProvider();
    await saveRecordInExecutor(database, record);
  }

  Future<void> saveRecordInExecutor(
    DatabaseExecutor executor,
    MaintenanceRecord record,
  ) async {
    final vehicleRows = await executor.query(
      'vehicles',
      columns: ['id'],
      where: 'id = ? AND user_id = ?',
      whereArgs: [record.vehicleId, record.userId],
      limit: 1,
    );
    if (vehicleRows.isEmpty) {
      throw StateError('Vehicle not found for this user.');
    }

    final existingRows = await executor.query(
      'maintenance_records',
      columns: ['id'],
      where: 'id = ? AND user_id = ?',
      whereArgs: [record.id, record.userId],
      limit: 1,
    );
    final values = record.toMap();

    if (existingRows.isEmpty) {
      await executor.insert('maintenance_records', values);
      return;
    }

    values
      ..remove('id')
      ..remove('user_id')
      ..remove('vehicle_id')
      ..remove('created_at')
      ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await executor.update(
      'maintenance_records',
      values,
      where: 'id = ? AND user_id = ?',
      whereArgs: [record.id, record.userId],
    );
  }
}
