import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revix/core/user_context.dart';
import 'package:revix/features/vehicle_management/data/vehicle_repository.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';
import 'package:revix/features/vehicle_management/presentation/vehicle_details_screen.dart';
import 'package:revix/features/vehicle_management/presentation/vehicle_visuals.dart';
import 'package:revix/features/vehicle_maintenance/data/maintenance_repository.dart';
import 'package:revix/features/vehicle_maintenance/data/maintenance_entry_service.dart';
import 'package:revix/features/vehicle_maintenance/domain/maintenance_record.dart';

void main() {
  late Vehicle vehicle;
  late _FakeVehicleRepository repository;

  setUp(() {
    vehicle = Vehicle(
      id: 'vehicle-1',
      name: 'Meu Civic',
      brand: 'Honda',
      model: 'Civic G10 EXL',
      yearModel: 2020,
      currentOdometer: 52000,
      fuelType: FuelType.flex,
    );
    repository = _FakeVehicleRepository(vehicle);
  });

  testWidgets(
    'keeps details visible above the action bar and opens card editing',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final size in [const Size(412, 915), const Size(1280, 720)]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            home: VehicleDetailsScreen(
              vehicle: vehicle,
              vehicleRepository: repository,
              maintenanceRepository: _FakeMaintenanceRepository([
                MaintenanceRecord(
                  vehicleId: vehicle.id,
                  title: 'Troca de óleo',
                  type: MaintenanceType.preventive,
                  date: DateTime(2026, 6, 1),
                ),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Atualizar km').hitTestable(), findsOneWidget);
        expect(tester.getSize(find.byType(ListView)).height, greaterThan(200));
        await tester.ensureVisible(find.text('Troca de óleo'));
        await tester.pumpAndSettle();
        final card = tester.getRect(
          find.ancestor(
            of: find.text('Troca de óleo'),
            matching: find.byType(Card),
          ),
        );
        final footer = tester.getRect(find.byType(SafeArea).last);
        expect(card.bottom, lessThanOrEqualTo(footer.top));
        await tester.tap(find.text('Troca de óleo'));
        await tester.pumpAndSettle();
        expect(find.text('Editar manutenção'), findsOneWidget);
        expect(find.text('Troca de óleo'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('updates vehicle odometer without saving a maintenance record', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDetailsScreen(
          vehicle: vehicle,
          vehicleRepository: repository,
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Atualizar km'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '52300');
    await tester.tap(find.text('Atualizar'));
    await tester.pumpAndSettle();

    expect(find.text('52.300'), findsOneWidget);
    expect(repository.odometerUpdateCount, 1);
    expect(repository.saveCount, 0);
  });

  testWidgets('shows the motorcycle category on vehicle details', (
    tester,
  ) async {
    final motorcycle = vehicle.copyWith(vehicleType: VehicleType.motorcycle);
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDetailsScreen(
          vehicle: motorcycle,
          vehicleRepository: repository,
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Motocicleta'), findsOneWidget);
    expect(find.byIcon(VehicleType.motorcycle.icon), findsOneWidget);
  });

  testWidgets('opens vehicle form prefilled for editing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDetailsScreen(
          vehicle: vehicle,
          vehicleRepository: repository,
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Opções do veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar veículo'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar veículo'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });

  testWidgets('filters maintenance timeline and includes inspections in all', (
    tester,
  ) async {
    final maintenanceRepository = _FakeMaintenanceRepository([
      MaintenanceRecord(
        id: 'inspection',
        vehicleId: vehicle.id,
        title: 'Revisão periódica',
        type: MaintenanceType.inspection,
        date: DateTime(2026, 6, 1),
      ),
      MaintenanceRecord(
        id: 'preventive',
        vehicleId: vehicle.id,
        title: 'Troca de óleo',
        type: MaintenanceType.preventive,
        date: DateTime(2026, 5, 1),
        odometerAtService: 51000,
      ),
      MaintenanceRecord(
        id: 'corrective',
        vehicleId: vehicle.id,
        title: 'Freios',
        type: MaintenanceType.corrective,
        date: DateTime(2026, 4, 1),
        odometerAtService: 50000,
      ),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDetailsScreen(
          vehicle: vehicle,
          vehicleRepository: repository,
          maintenanceRepository: maintenanceRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Revisão periódica'), findsOneWidget);
    expect(find.textContaining('km não informado'), findsOneWidget);
    expect(find.text('Troca de óleo'), findsOneWidget);
    expect(find.text('Freios'), findsOneWidget);

    await tester.tap(find.text('Preventivas'));
    await tester.pumpAndSettle();
    expect(find.text('Troca de óleo'), findsOneWidget);
    expect(find.text('Freios'), findsNothing);
    expect(find.text('Revisão periódica'), findsNothing);

    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    expect(find.text('Revisão periódica'), findsOneWidget);
  });

  testWidgets(
    'creates a maintenance record from details and refreshes history',
    (tester) async {
      final maintenanceRepository = _FakeMaintenanceRepository();
      final saver = _FakeMaintenanceSaver(maintenanceRepository);
      await tester.pumpWidget(
        MaterialApp(
          home: VehicleDetailsScreen(
            vehicle: vehicle,
            vehicleRepository: repository,
            maintenanceRepository: maintenanceRepository,
            maintenanceSaver: saver,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar ação'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Troca de óleo');
      await tester.tap(find.text('Salvar manutenção'));
      await tester.pumpAndSettle();

      expect(saver.saved, hasLength(1));
      expect(saver.saved.single.vehicleId, vehicle.id);
      await tester.drag(find.byType(ListView).first, const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(find.text('Troca de óleo'), findsOneWidget);
    },
  );

  testWidgets('declining the higher odometer prompt does not save a record', (
    tester,
  ) async {
    final saver = _OdometerCheckingSaver();
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDetailsScreen(
          vehicle: vehicle,
          vehicleRepository: repository,
          maintenanceRepository: _FakeMaintenanceRepository(),
          maintenanceSaver: saver,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar ação'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Revisão');
    await tester.enterText(find.byType(TextFormField).at(1), '53000');
    await tester.tap(find.text('Salvar manutenção'));
    await tester.pumpAndSettle();
    expect(find.textContaining('é superior ao km atual'), findsOneWidget);
    await tester.tap(find.text('Não, cancelar'));
    await tester.pumpAndSettle();
    expect(saver.saved, isEmpty);
    expect(find.text('52.000'), findsOneWidget);
  });

  testWidgets(
    'confirming higher odometer saves record and updates displayed vehicle km',
    (tester) async {
      final saver = _OdometerCheckingSaver();
      await tester.pumpWidget(
        MaterialApp(
          home: VehicleDetailsScreen(
            vehicle: vehicle,
            vehicleRepository: repository,
            maintenanceRepository: _FakeMaintenanceRepository(),
            maintenanceSaver: saver,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar ação'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Revisão');
      await tester.enterText(find.byType(TextFormField).at(1), '53000');
      await tester.tap(find.text('Salvar manutenção'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atualizar e salvar'));
      await tester.pumpAndSettle();
      expect(saver.saved, hasLength(1));
      expect(saver.currentOdometer, 53000);
      expect(find.text('53.000'), findsOneWidget);
    },
  );
}

class _FakeMaintenanceRepository implements MaintenanceRepository {
  _FakeMaintenanceRepository([List<MaintenanceRecord> records = const []])
    : records = [...records];
  final List<MaintenanceRecord> records;

  @override
  Future<MaintenanceRecord?> getRecord({
    required String id,
    String userId = mockUserId,
  }) async => null;
  @override
  Future<List<MaintenanceRecord>> getRecordsForVehicle({
    required String vehicleId,
    String userId = mockUserId,
  }) async => records;
  @override
  Future<void> saveRecord(MaintenanceRecord record) async {
    records.removeWhere((existing) => existing.id == record.id);
    records.add(record);
  }
}

class _FakeMaintenanceSaver implements MaintenanceRecordSaver {
  _FakeMaintenanceSaver(this.repository);
  final _FakeMaintenanceRepository repository;
  final List<MaintenanceRecord> saved = [];

  @override
  Future<void> save(
    MaintenanceRecord record, {
    bool confirmOdometerUpdate = false,
  }) async {
    saved.add(record);
    await repository.saveRecord(record);
  }
}

class _OdometerCheckingSaver implements MaintenanceRecordSaver {
  int currentOdometer = 52000;
  final List<MaintenanceRecord> saved = [];

  @override
  Future<void> save(
    MaintenanceRecord record, {
    bool confirmOdometerUpdate = false,
  }) async {
    final serviceOdometer = record.odometerAtService;
    if (serviceOdometer != null &&
        serviceOdometer > currentOdometer &&
        !confirmOdometerUpdate) {
      throw OdometerUpdateConfirmationRequired(
        currentOdometer,
        serviceOdometer,
      );
    }
    if (serviceOdometer != null && serviceOdometer > currentOdometer) {
      currentOdometer = serviceOdometer;
    }
    saved.add(record);
  }
}

class _FakeVehicleRepository implements VehicleRepository {
  _FakeVehicleRepository(this.vehicle);

  Vehicle vehicle;
  int odometerUpdateCount = 0;
  int saveCount = 0;

  @override
  Future<Vehicle?> getVehicle({
    required String id,
    String userId = mockUserId,
  }) async => vehicle.id == id && vehicle.userId == userId ? vehicle : null;

  @override
  Future<List<Vehicle>> getActiveVehicles({String userId = mockUserId}) async =>
      vehicle.userId == userId && vehicle.archivedAt == null ? [vehicle] : [];

  @override
  Future<List<Vehicle>> getArchivedVehicles({
    String userId = mockUserId,
  }) async =>
      vehicle.userId == userId && vehicle.archivedAt != null ? [vehicle] : [];

  @override
  Future<void> saveVehicle(Vehicle updatedVehicle) async {
    vehicle = updatedVehicle;
    saveCount++;
  }

  @override
  Future<void> updateCurrentOdometer({
    required String id,
    required int odometer,
    String userId = mockUserId,
  }) async {
    if (vehicle.id != id || vehicle.userId != userId) {
      throw StateError('Vehicle not found for this user.');
    }
    vehicle = vehicle.copyWith(
      currentOdometer: odometer,
      updatedAt: DateTime.now().toUtc(),
    );
    odometerUpdateCount++;
  }

  @override
  Future<void> archiveVehicle({
    required String id,
    String userId = mockUserId,
  }) => throw UnimplementedError();

  @override
  Future<void> restoreVehicle({
    required String id,
    String userId = mockUserId,
  }) => throw UnimplementedError();
}
