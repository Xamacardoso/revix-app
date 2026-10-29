import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const int schemaVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database case final database?) return database;
    final database = await _openApplicationDatabase();
    _database = database;
    return database;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _openApplicationDatabase() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      final supportDirectory = await getApplicationSupportDirectory();
      final appDirectory = Directory(path.join(supportDirectory.path, 'revix'));
      await appDirectory.create(recursive: true);
      return openAtPath(
        path.join(appDirectory.path, 'revix.db'),
        factory: databaseFactoryFfi,
      );
    }

    return openAtPath(
      path.join(await sqflite.getDatabasesPath(), 'revix.db'),
      factory: sqflite.databaseFactory,
    );
  }

  static Future<Database> openAtPath(
    String databasePath, {
    required DatabaseFactory factory,
  }) {
    return factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) => _runMigrations(database, 0, version),
        onUpgrade: _runMigrations,
        onDowngrade: (database, oldVersion, newVersion) {
          throw StateError(
            'Database downgrade from $oldVersion to $newVersion is unsupported.',
          );
        },
      ),
    );
  }

  static Future<void> _runMigrations(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      final migration = _migrations[version];
      if (migration == null) {
        throw StateError('Missing database migration for version $version.');
      }
      await migration(database);
    }
  }

  static final Map<int, Future<void> Function(Database)> _migrations = {
    1: _createSchemaV1,
    2: _migrateMaintenanceOdometerToOptional,
    3: _addVehicleType,
  };

  static Future<void> _createSchemaV1(Database database) async {
    await database.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year_manufacture INTEGER,
        year_model INTEGER NOT NULL,
        plate TEXT,
        current_odometer INTEGER NOT NULL CHECK (current_odometer >= 0),
        fuel_type TEXT NOT NULL CHECK (
          fuel_type IN ('GASOLINE', 'ETHANOL', 'FLEX', 'DIESEL', 'ELECTRIC', 'HYBRID')
        ),
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
        type TEXT NOT NULL CHECK (type IN ('PREVENTIVE', 'CORRECTIVE', 'INSPECTION')),
        date TEXT NOT NULL,
        odometer_at_service INTEGER NOT NULL CHECK (odometer_at_service >= 0),
        cost_parts INTEGER,
        cost_labor INTEGER,
        total_cost INTEGER,
        service_provider TEXT,
        notes TEXT,
        next_recommended_date TEXT,
        next_recommended_odometer INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id, user_id)
          REFERENCES vehicles (id, user_id) ON DELETE RESTRICT
      )
    ''');

    await database.execute(
      'CREATE INDEX idx_vehicles_user_archive ON vehicles (user_id, archived_at)',
    );
    await database.execute(
      'CREATE INDEX idx_maintenance_vehicle_date '
      'ON maintenance_records (vehicle_id, date DESC)',
    );
    await database.execute(
      'CREATE INDEX idx_maintenance_user ON maintenance_records (user_id)',
    );
  }

  static Future<void> _migrateMaintenanceOdometerToOptional(
    Database database,
  ) async {
    await database.execute('''
      CREATE TABLE maintenance_records_v2 (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        vehicle_id TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('PREVENTIVE', 'CORRECTIVE', 'INSPECTION')),
        date TEXT NOT NULL,
        odometer_at_service INTEGER CHECK (odometer_at_service IS NULL OR odometer_at_service >= 0),
        cost_parts INTEGER,
        cost_labor INTEGER,
        total_cost INTEGER,
        service_provider TEXT,
        notes TEXT,
        next_recommended_date TEXT,
        next_recommended_odometer INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id, user_id)
          REFERENCES vehicles (id, user_id) ON DELETE RESTRICT
      )
    ''');
    await database.execute('''
      INSERT INTO maintenance_records_v2 (
        id, user_id, vehicle_id, title, type, date, odometer_at_service,
        cost_parts, cost_labor, total_cost, service_provider, notes,
        next_recommended_date, next_recommended_odometer, created_at, updated_at
      )
      SELECT id, user_id, vehicle_id, title, type, date, odometer_at_service,
        cost_parts, cost_labor, total_cost, service_provider, notes,
        next_recommended_date, next_recommended_odometer, created_at, updated_at
      FROM maintenance_records
    ''');
    await database.execute('DROP TABLE maintenance_records');
    await database.execute(
      'ALTER TABLE maintenance_records_v2 RENAME TO maintenance_records',
    );
    await database.execute(
      'CREATE INDEX idx_maintenance_vehicle_date '
      'ON maintenance_records (vehicle_id, date DESC)',
    );
    await database.execute(
      'CREATE INDEX idx_maintenance_user ON maintenance_records (user_id)',
    );
  }

  static Future<void> _addVehicleType(Database database) async {
    await database.execute('''
      ALTER TABLE vehicles
      ADD COLUMN vehicle_type TEXT NOT NULL DEFAULT 'CAR'
      CHECK (vehicle_type IN ('CAR', 'MOTORCYCLE', 'TRUCK', 'VAN', 'BUS', 'OTHER'))
    ''');
  }
}
