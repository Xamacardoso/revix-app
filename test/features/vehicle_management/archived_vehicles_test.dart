import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revix/core/user_context.dart';
import 'package:revix/features/vehicle_management/data/vehicle_repository.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';
import 'package:revix/features/vehicle_management/presentation/archived_vehicles_screen.dart';

void main() {
  testWidgets('lists archived vehicles and restores one to the active garage', (
    tester,
  ) async {
    final repository = _FakeVehicleRepository();
    await tester.pumpWidget(
      MaterialApp(home: ArchivedVehiclesScreen(vehicleRepository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meu Civic'), findsOneWidget);
    await tester.tap(find.text('Restaurar'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum veículo arquivado.'), findsOneWidget);
    expect(await repository.getActiveVehicles(), hasLength(1));
  });
}

class _FakeVehicleRepository implements VehicleRepository {
  Vehicle vehicle = Vehicle(
    id: 'vehicle-archived',
    name: 'Meu Civic',
    brand: 'Honda',
    model: 'Civic',
    yearModel: 2020,
    currentOdometer: 50000,
    fuelType: FuelType.flex,
    archivedAt: DateTime.utc(2026),
  );

  Vehicle _withArchivedAt(DateTime? archivedAt) => Vehicle(
    id: vehicle.id,
    userId: vehicle.userId,
    name: vehicle.name,
    brand: vehicle.brand,
    model: vehicle.model,
    yearModel: vehicle.yearModel,
    currentOdometer: vehicle.currentOdometer,
    fuelType: vehicle.fuelType,
    archivedAt: archivedAt,
    createdAt: vehicle.createdAt,
    updatedAt: DateTime.now().toUtc(),
  );

  @override
  Future<Vehicle?> getVehicle({
    required String id,
    String userId = mockUserId,
  }) async => id == vehicle.id && userId == vehicle.userId ? vehicle : null;

  @override
  Future<List<Vehicle>> getActiveVehicles({String userId = mockUserId}) async =>
      userId == vehicle.userId && vehicle.archivedAt == null ? [vehicle] : [];

  @override
  Future<List<Vehicle>> getArchivedVehicles({
    String userId = mockUserId,
  }) async =>
      userId == vehicle.userId && vehicle.archivedAt != null ? [vehicle] : [];

  @override
  Future<void> saveVehicle(Vehicle value) async => vehicle = value;

  @override
  Future<void> updateCurrentOdometer({
    required String id,
    required int odometer,
    String userId = mockUserId,
  }) async {}

  @override
  Future<void> archiveVehicle({
    required String id,
    String userId = mockUserId,
  }) async {
    vehicle = _withArchivedAt(DateTime.now().toUtc());
  }

  @override
  Future<void> restoreVehicle({
    required String id,
    String userId = mockUserId,
  }) async {
    vehicle = _withArchivedAt(null);
  }
}
