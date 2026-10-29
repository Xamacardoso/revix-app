import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:revix/data/local/app_database.dart';
import 'package:revix/features/vehicle_management/data/sqlite_vehicle_repository.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';
import 'package:revix/features/vehicle_maintenance/data/sqlite_maintenance_repository.dart';
import 'package:revix/features/vehicle_maintenance/domain/maintenance_record.dart';
import 'package:revix/features/vehicle_maintenance/data/maintenance_entry_service.dart';

void main() {
  late Directory temporaryDirectory;
  late Database database;
  late SqliteVehicleRepository vehicleRepository;
  late SqliteMaintenanceRepository maintenanceRepository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'revix-repo-test-',
    );
    database = await AppDatabase.openAtPath(
      path.join(temporaryDirectory.path, 'test.db'),
      factory: databaseFactoryFfi,
    );
    vehicleRepository = SqliteVehicleRepository(
      databaseProvider: () async => database,
    );
    maintenanceRepository = SqliteMaintenanceRepository(
      databaseProvider: () async => database,
    );
  });

  tearDown(() async {
    await database.close();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'vehicle and maintenance repositories use stable IDs and mock user',
    () async {
      final vehicle = Vehicle(
        name: 'Meu Civic',
        brand: 'Honda',
        model: 'Civic G10 EXL',
        yearModel: 2020,
        currentOdometer: 50000,
        fuelType: FuelType.flex,
      );
      await vehicleRepository.saveVehicle(vehicle);

      expect(vehicle.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
      final savedVehicle = await vehicleRepository.getVehicle(id: vehicle.id);
      expect(savedVehicle?.userId, 'mock_user_default');
      expect(savedVehicle?.fuelType, FuelType.flex);
      expect(savedVehicle?.vehicleType, VehicleType.car);

      final motorcycle = Vehicle(
        name: 'Moto de viagem',
        brand: 'Honda',
        model: 'CB 500X',
        yearModel: 2023,
        currentOdometer: 12000,
        fuelType: FuelType.gasoline,
        vehicleType: VehicleType.motorcycle,
      );
      await vehicleRepository.saveVehicle(motorcycle);
      expect(
        (await vehicleRepository.getVehicle(id: motorcycle.id))?.vehicleType,
        VehicleType.motorcycle,
      );

      final maintenance = MaintenanceRecord(
        vehicleId: vehicle.id,
        title: 'Troca de óleo',
        type: MaintenanceType.preventive,
        date: DateTime(2026, 1, 1),
        odometerAtService: 49000,
      );
      await maintenanceRepository.saveRecord(maintenance);

      expect(maintenance.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
      final savedMaintenance = await maintenanceRepository.getRecord(
        id: maintenance.id,
      );
      expect(savedMaintenance?.userId, 'mock_user_default');
      expect(savedMaintenance?.vehicleId, vehicle.id);
    },
  );

  test(
    'vehicle archival preserves maintenance and restoration returns vehicle',
    () async {
      final vehicle = Vehicle(
        name: 'Carro da Firma',
        brand: 'Honda',
        model: 'Civic',
        yearModel: 2022,
        currentOdometer: 30000,
        fuelType: FuelType.gasoline,
      );
      await vehicleRepository.saveVehicle(vehicle);
      await maintenanceRepository.saveRecord(
        MaintenanceRecord(
          vehicleId: vehicle.id,
          title: 'Inspeção periódica',
          type: MaintenanceType.inspection,
          date: DateTime(2026, 2, 1),
          odometerAtService: 29000,
        ),
      );

      await vehicleRepository.archiveVehicle(id: vehicle.id);
      expect(await vehicleRepository.getActiveVehicles(), isEmpty);
      expect(await vehicleRepository.getArchivedVehicles(), hasLength(1));
      expect(
        await maintenanceRepository.getRecordsForVehicle(vehicleId: vehicle.id),
        hasLength(1),
      );

      await vehicleRepository.restoreVehicle(id: vehicle.id);
      expect(await vehicleRepository.getArchivedVehicles(), isEmpty);
      expect(await vehicleRepository.getActiveVehicles(), hasLength(1));
    },
  );

  test(
    'maintenance repository orders records newest first and keeps record identity on update',
    () async {
      final vehicle = Vehicle(
        name: 'Daily',
        brand: 'Honda',
        model: 'Fit',
        yearModel: 2018,
        currentOdometer: 80000,
        fuelType: FuelType.flex,
      );
      await vehicleRepository.saveVehicle(vehicle);

      final older = MaintenanceRecord(
        vehicleId: vehicle.id,
        title: 'Troca de filtro',
        type: MaintenanceType.preventive,
        date: DateTime(2025, 5, 1),
        odometerAtService: 70000,
      );
      final newer = MaintenanceRecord(
        vehicleId: vehicle.id,
        title: 'Freios',
        type: MaintenanceType.corrective,
        date: DateTime(2026, 3, 1),
        odometerAtService: 79000,
      );
      await maintenanceRepository.saveRecord(older);
      await maintenanceRepository.saveRecord(newer);

      final records = await maintenanceRepository.getRecordsForVehicle(
        vehicleId: vehicle.id,
      );
      expect(records.map((record) => record.id), [newer.id, older.id]);

      await maintenanceRepository.saveRecord(
        MaintenanceRecord(
          id: newer.id,
          vehicleId: vehicle.id,
          title: 'Revisão dos freios',
          type: MaintenanceType.corrective,
          date: newer.date,
          odometerAtService: newer.odometerAtService,
          createdAt: newer.createdAt,
        ),
      );
      final updated = await maintenanceRepository.getRecord(id: newer.id);
      expect(updated?.id, newer.id);
      expect(updated?.title, 'Revisão dos freios');
    },
  );

  test(
    'quick odometer update persists without creating a maintenance record',
    () async {
      final vehicle = Vehicle(
        name: 'Meu Civic',
        brand: 'Honda',
        model: 'Civic',
        yearModel: 2020,
        currentOdometer: 52000,
        fuelType: FuelType.flex,
      );
      await vehicleRepository.saveVehicle(vehicle);

      await vehicleRepository.updateCurrentOdometer(
        id: vehicle.id,
        odometer: 52300,
      );

      final updatedVehicle = await vehicleRepository.getVehicle(id: vehicle.id);
      expect(updatedVehicle?.currentOdometer, 52300);
      expect(
        await maintenanceRepository.getRecordsForVehicle(vehicleId: vehicle.id),
        isEmpty,
      );
    },
  );

  test(
    'higher maintenance odometer requires confirmation and commits atomically',
    () async {
      final vehicle = Vehicle(
        name: 'Meu Civic',
        brand: 'Honda',
        model: 'Civic',
        yearModel: 2020,
        currentOdometer: 52000,
        fuelType: FuelType.flex,
      );
      await vehicleRepository.saveVehicle(vehicle);
      final service = MaintenanceEntryService(
        databaseProvider: () async => database,
        vehicleRepository: vehicleRepository,
        maintenanceRepository: maintenanceRepository,
      );
      final record = MaintenanceRecord(
        vehicleId: vehicle.id,
        title: 'Revisão',
        type: MaintenanceType.preventive,
        date: DateTime(2026, 5, 1),
        odometerAtService: 53000,
      );

      await expectLater(
        service.save(record),
        throwsA(isA<OdometerUpdateConfirmationRequired>()),
      );
      expect(
        (await vehicleRepository.getVehicle(id: vehicle.id))?.currentOdometer,
        52000,
      );
      expect(
        await maintenanceRepository.getRecordsForVehicle(vehicleId: vehicle.id),
        isEmpty,
      );

      await service.save(record, confirmOdometerUpdate: true);
      expect(
        (await vehicleRepository.getVehicle(id: vehicle.id))?.currentOdometer,
        53000,
      );
      expect(
        await maintenanceRepository.getRecordsForVehicle(vehicleId: vehicle.id),
        hasLength(1),
      );
    },
  );

  test(
    'maintenance without service odometer saves without changing vehicle odometer',
    () async {
      final vehicle = Vehicle(
        name: 'Meu Civic',
        brand: 'Honda',
        model: 'Civic',
        yearModel: 2020,
        currentOdometer: 52000,
        fuelType: FuelType.flex,
      );
      await vehicleRepository.saveVehicle(vehicle);
      final service = MaintenanceEntryService(
        databaseProvider: () async => database,
        vehicleRepository: vehicleRepository,
        maintenanceRepository: maintenanceRepository,
      );
      final record = MaintenanceRecord(
        vehicleId: vehicle.id,
        title: 'Inspeção visual',
        type: MaintenanceType.inspection,
        date: DateTime(2026, 6, 1),
      );

      await service.save(record);
      expect(
        (await vehicleRepository.getVehicle(id: vehicle.id))?.currentOdometer,
        52000,
      );
      final saved = await maintenanceRepository.getRecord(id: record.id);
      expect(saved?.odometerAtService, isNull);
    },
  );
}
