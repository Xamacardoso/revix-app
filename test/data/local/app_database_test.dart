import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:revix/data/local/app_database.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';

void main() {
  late Directory temporaryDirectory;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'revix-db-test-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'creates versioned vehicle and maintenance tables and persists records',
    () async {
      final databasePath = path.join(temporaryDirectory.path, 'test.db');
      final database = await AppDatabase.openAtPath(
        databasePath,
        factory: databaseFactoryFfi,
      );

      expect(await database.getVersion(), AppDatabase.schemaVersion);

      final tableRows = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final tableNames = tableRows.map((row) => row['name']).toSet();
      expect(tableNames, containsAll(['vehicles', 'maintenance_records']));

      final now = DateTime.utc(2026, 1, 1).toIso8601String();
      await database.insert('vehicles', {
        'id': 'vehicle-1',
        'user_id': 'mock_user_default',
        'name': 'Meu Civic',
        'brand': 'Honda',
        'model': 'Civic G10 EXL',
        'year_model': 2020,
        'current_odometer': 50000,
        'fuel_type': 'FLEX',
        'created_at': now,
        'updated_at': now,
      });
      await database.insert('maintenance_records', {
        'id': 'maintenance-1',
        'user_id': 'mock_user_default',
        'vehicle_id': 'vehicle-1',
        'title': 'Troca de óleo',
        'type': 'PREVENTIVE',
        'date': '2026-01-01',
        'odometer_at_service': 49000,
        'created_at': now,
        'updated_at': now,
      });
      await database.close();

      final reopenedDatabase = await AppDatabase.openAtPath(
        databasePath,
        factory: databaseFactoryFfi,
      );
      final records = await reopenedDatabase.query('maintenance_records');
      expect(records, hasLength(1));
      expect(records.single['vehicle_id'], 'vehicle-1');
      await reopenedDatabase.close();
    },
  );

  test('rejects a maintenance record without an existing vehicle', () async {
    final database = await AppDatabase.openAtPath(
      path.join(temporaryDirectory.path, 'foreign-key.db'),
      factory: databaseFactoryFfi,
    );
    final now = DateTime.utc(2026, 1, 1).toIso8601String();

    await expectLater(
      database.insert('maintenance_records', {
        'id': 'maintenance-1',
        'user_id': 'mock_user_default',
        'vehicle_id': 'missing-vehicle',
        'title': 'Troca de óleo',
        'type': 'PREVENTIVE',
        'date': '2026-01-01',
        'odometer_at_service': 49000,
        'created_at': now,
        'updated_at': now,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await database.close();
  });

  test(
    'v3 migration adds a default car type to existing v2 vehicles',
    () async {
      final databasePath = path.join(temporaryDirectory.path, 'legacy-v2.db');
      final versionTwoDatabase = await AppDatabase.openAtPath(
        databasePath,
        factory: databaseFactoryFfi,
      );
      await versionTwoDatabase.insert('vehicles', {
        'id': 'vehicle-v2',
        'user_id': 'mock_user_default',
        'name': 'Meu carro',
        'brand': 'Honda',
        'model': 'Fit',
        'year_model': 2020,
        'current_odometer': 80000,
        'fuel_type': 'FLEX',
        'created_at': '2025-01-01T00:00:00.000Z',
        'updated_at': '2025-01-01T00:00:00.000Z',
      });
      await versionTwoDatabase.execute(
        'ALTER TABLE vehicles DROP COLUMN vehicle_type',
      );
      await versionTwoDatabase.setVersion(2);
      await versionTwoDatabase.close();

      final migratedDatabase = await AppDatabase.openAtPath(
        databasePath,
        factory: databaseFactoryFfi,
      );
      expect(await migratedDatabase.getVersion(), 3);
      final migratedVehicles = await migratedDatabase.query('vehicles');
      expect(migratedVehicles.single['name'], 'Meu carro');
      expect(migratedVehicles.single['vehicle_type'], 'CAR');
      await migratedDatabase.close();
    },
  );

  test(
    'v2 migration preserves v1 maintenance and allows a missing service odometer',
    () async {
      final databasePath = path.join(temporaryDirectory.path, 'legacy-v1.db');
      final legacyDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (database) async =>
              database.execute('PRAGMA foreign_keys = ON'),
          onCreate: (database, _) async {
            await database.execute('''
            CREATE TABLE vehicles (
              id TEXT NOT NULL,
              user_id TEXT NOT NULL,
              name TEXT NOT NULL,
              brand TEXT NOT NULL,
              model TEXT NOT NULL,
              year_manufacture INTEGER,
              year_model INTEGER NOT NULL,
              plate TEXT,
              current_odometer INTEGER NOT NULL,
              fuel_type TEXT NOT NULL,
              archived_at TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              UNIQUE (id, user_id)
            )
          ''');
            await database.execute('''
            CREATE TABLE maintenance_records (
              id TEXT PRIMARY KEY NOT NULL,
              user_id TEXT NOT NULL,
              vehicle_id TEXT NOT NULL,
              title TEXT NOT NULL,
              type TEXT NOT NULL,
              date TEXT NOT NULL,
              odometer_at_service INTEGER NOT NULL,
              cost_parts INTEGER,
              cost_labor INTEGER,
              total_cost INTEGER,
              service_provider TEXT,
              notes TEXT,
              next_recommended_date TEXT,
              next_recommended_odometer INTEGER,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY (vehicle_id, user_id) REFERENCES vehicles (id, user_id)
            )
          ''');
            await database.execute(
              'CREATE INDEX idx_maintenance_vehicle_date ON maintenance_records (vehicle_id, date DESC)',
            );
            await database.execute(
              'CREATE INDEX idx_maintenance_user ON maintenance_records (user_id)',
            );
            const timestamp = '2025-01-01T00:00:00.000Z';
            await database.insert('vehicles', {
              'id': 'vehicle-v1',
              'user_id': 'mock_user_default',
              'name': 'Meu carro',
              'brand': 'Honda',
              'model': 'Fit',
              'year_model': 2020,
              'current_odometer': 80000,
              'fuel_type': 'FLEX',
              'created_at': timestamp,
              'updated_at': timestamp,
            });
            await database.insert('maintenance_records', {
              'id': 'maintenance-v1',
              'user_id': 'mock_user_default',
              'vehicle_id': 'vehicle-v1',
              'title': 'Troca de óleo',
              'type': 'PREVENTIVE',
              'date': '2025-01-01',
              'odometer_at_service': 79000,
              'created_at': timestamp,
              'updated_at': timestamp,
            });
          },
        ),
      );
      await legacyDatabase.close();

      final migratedDatabase = await AppDatabase.openAtPath(
        databasePath,
        factory: databaseFactoryFfi,
      );
      expect(await migratedDatabase.getVersion(), 3);
      final existing = await migratedDatabase.query('maintenance_records');
      expect(existing, hasLength(1));
      expect(existing.single['odometer_at_service'], 79000);
      final existingVehicle = await migratedDatabase.query('vehicles');
      expect(existingVehicle.single['vehicle_type'], 'CAR');
      expect(
        Vehicle.fromMap(existingVehicle.single).vehicleType,
        VehicleType.car,
      );

      await migratedDatabase.insert('maintenance_records', {
        'id': 'maintenance-no-odometer',
        'user_id': 'mock_user_default',
        'vehicle_id': 'vehicle-v1',
        'title': 'Inspeção visual',
        'type': 'INSPECTION',
        'date': '2025-02-01',
        'odometer_at_service': null,
        'created_at': '2025-02-01T00:00:00.000Z',
        'updated_at': '2025-02-01T00:00:00.000Z',
      });
      final rows = await migratedDatabase.query(
        'maintenance_records',
        where: 'id = ?',
        whereArgs: ['maintenance-no-odometer'],
      );
      expect(rows.single['odometer_at_service'], isNull);
      final indexes = await migratedDatabase.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index'",
      );
      expect(
        indexes.map((row) => row['name']),
        containsAll(['idx_maintenance_vehicle_date', 'idx_maintenance_user']),
      );
      await migratedDatabase.close();
    },
  );
}
