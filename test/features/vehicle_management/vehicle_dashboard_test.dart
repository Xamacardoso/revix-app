import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revix/core/user_context.dart';
import 'package:revix/features/vehicle_management/data/vehicle_repository.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';
import 'package:revix/features/vehicle_management/presentation/vehicle_dashboard_screen.dart';
import 'package:revix/features/vehicle_management/presentation/vehicle_visuals.dart';
import 'package:revix/features/vehicle_maintenance/data/maintenance_repository.dart';
import 'package:revix/features/vehicle_maintenance/domain/maintenance_record.dart';

void main() {
  testWidgets('shows an empty garage and an add-vehicle action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDashboardScreen(
          vehicleRepository: _FakeVehicleRepository(),
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sua garagem está vazia'), findsOneWidget);
    expect(find.text('Adicionar primeiro veículo'), findsOneWidget);
  });

  testWidgets('shows active vehicle card and selected vehicle summary', (
    tester,
  ) async {
    final vehicle = Vehicle(
      name: 'Meu Civic',
      brand: 'Honda',
      model: 'Civic G10 EXL',
      yearModel: 2020,
      plate: 'ABC-1234',
      currentOdometer: 52300,
      fuelType: FuelType.flex,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDashboardScreen(
          vehicleRepository: _FakeVehicleRepository([vehicle]),
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meu Civic'), findsWidgets);
    expect(find.text('Honda Civic G10 EXL'), findsWidgets);
    expect(find.text('ABC-1234'), findsOneWidget);
    expect(find.text('52.300 km'), findsNWidgets(2));
    expect(find.text('Visão rápida'), findsOneWidget);
  });

  testWidgets('searches active vehicles by plate in the vertical list', (
    tester,
  ) async {
    final vehicles = [
      Vehicle(
        id: 'civic',
        name: 'Meu Civic',
        brand: 'Honda',
        model: 'Civic EXL',
        yearModel: 2020,
        plate: 'ABC1D23',
        currentOdometer: 52000,
        fuelType: FuelType.flex,
      ),
      Vehicle(
        id: 'fit',
        name: 'Carro da Firma',
        brand: 'Honda',
        model: 'Fit',
        yearModel: 2019,
        plate: 'XYZ4E56',
        currentOdometer: 80000,
        fuelType: FuelType.gasoline,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDashboardScreen(
          vehicleRepository: _FakeVehicleRepository(vehicles),
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Listagem rápida'), findsOneWidget);
    expect(find.text('Todos os veículos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(TextField),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'xyz4e56');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Carro da Firma'), findsWidgets);
    expect(find.text('Nenhum veículo encontrado.'), findsNothing);

    await tester.enterText(find.byType(TextField), 'no-match');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum veículo encontrado.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('shows motorcycles with their category label and icon', (
    tester,
  ) async {
    final motorcycle = Vehicle(
      id: 'dashboard-motorcycle',
      name: 'Moto de viagem',
      brand: 'Honda',
      model: 'CB 500X',
      yearModel: 2023,
      currentOdometer: 12000,
      fuelType: FuelType.gasoline,
      vehicleType: VehicleType.motorcycle,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDashboardScreen(
          vehicleRepository: _FakeVehicleRepository([motorcycle]),
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Motocicleta'), findsWidgets);
    expect(find.byIcon(VehicleType.motorcycle.icon), findsWidgets);
  });

  testWidgets('selecting a vehicle in the vertical list highlights its row', (
    tester,
  ) async {
    final first = Vehicle(
      id: 'first',
      name: 'Carro um',
      brand: 'Honda',
      model: 'Civic',
      yearModel: 2020,
      currentOdometer: 52000,
      fuelType: FuelType.flex,
    );
    final second = Vehicle(
      id: 'second',
      name: 'Carro dois',
      brand: 'Toyota',
      model: 'Corolla',
      yearModel: 2022,
      currentOdometer: 41000,
      fuelType: FuelType.gasoline,
    );
    final maintenanceRepository = _FakeMaintenanceRepository([
      MaintenanceRecord(
        id: 'summary-second',
        vehicleId: second.id,
        title: 'Revisão Corolla',
        type: MaintenanceType.inspection,
        date: DateTime(2026, 9, 1),
      ),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDashboardScreen(
          vehicleRepository: _FakeVehicleRepository([first, second]),
          maintenanceRepository: maintenanceRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final secondRow = find.byKey(const Key('vehicle-row-second'));
    await tester.ensureVisible(secondRow);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).last);
    await tester.pumpAndSettle();
    expect(tester.widget<Card>(secondRow).color, isNotNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.textContaining('Última ação: Revisão Corolla'), findsOneWidget);
  });

  testWidgets(
    'shows maintenance spending and latest service for selected vehicle',
    (tester) async {
      final vehicle = Vehicle(
        id: 'summary-car',
        name: 'Meu Civic',
        brand: 'Honda',
        model: 'Civic',
        yearModel: 2020,
        currentOdometer: 52300,
        fuelType: FuelType.flex,
      );
      final repository = _FakeMaintenanceRepository([
        MaintenanceRecord(
          id: 'latest',
          vehicleId: vehicle.id,
          title: 'Troca de óleo',
          type: MaintenanceType.preventive,
          date: DateTime(2026, 6, 1),
          odometerAtService: 52000,
          costPartsCents: 5000,
          costLaborCents: 3000,
        ),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          home: VehicleDashboardScreen(
            vehicleRepository: _FakeVehicleRepository([vehicle]),
            maintenanceRepository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Gastos registrados'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Gastos registrados: R\$ 80,00'), findsOneWidget);
      expect(
        find.text('Última ação: Troca de óleo • 01/06/2026'),
        findsOneWidget,
      );
    },
  );

  testWidgets('opens details for the selected vehicle from the dashboard', (
    tester,
  ) async {
    final vehicle = Vehicle(
      id: 'navigate-car',
      name: 'Carro da Firma',
      brand: 'Honda',
      model: 'Fit',
      yearModel: 2019,
      currentOdometer: 80000,
      fuelType: FuelType.flex,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleDashboardScreen(
          vehicleRepository: _FakeVehicleRepository([vehicle]),
          maintenanceRepository: _FakeMaintenanceRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Ver detalhes'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ver detalhes'));
    await tester.pumpAndSettle();
    expect(find.text('Dados do veículo'), findsOneWidget);
    expect(find.text('Quilometragem atual'), findsOneWidget);
  });
}

class _FakeMaintenanceRepository implements MaintenanceRepository {
  _FakeMaintenanceRepository([this.records = const []]);
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
  }) async => records.where((record) => record.vehicleId == vehicleId).toList();
  @override
  Future<void> saveRecord(MaintenanceRecord record) async {}
}

class _FakeVehicleRepository implements VehicleRepository {
  _FakeVehicleRepository([List<Vehicle> vehicles = const []])
    : _vehicles = [...vehicles];

  final List<Vehicle> _vehicles;

  @override
  Future<Vehicle?> getVehicle({
    required String id,
    String userId = mockUserId,
  }) async {
    for (final vehicle in _vehicles) {
      if (vehicle.id == id && vehicle.userId == userId) return vehicle;
    }
    return null;
  }

  @override
  Future<List<Vehicle>> getActiveVehicles({String userId = mockUserId}) async =>
      _vehicles
          .where(
            (vehicle) => vehicle.userId == userId && vehicle.archivedAt == null,
          )
          .toList();

  @override
  Future<List<Vehicle>> getArchivedVehicles({
    String userId = mockUserId,
  }) async => _vehicles
      .where(
        (vehicle) => vehicle.userId == userId && vehicle.archivedAt != null,
      )
      .toList();

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {
    _vehicles.removeWhere((existing) => existing.id == vehicle.id);
    _vehicles.add(vehicle);
  }

  @override
  Future<void> updateCurrentOdometer({
    required String id,
    required int odometer,
    String userId = mockUserId,
  }) => throw UnimplementedError();

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
