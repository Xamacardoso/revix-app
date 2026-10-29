import 'package:flutter_test/flutter_test.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';

void main() {
  test('reads a legacy vehicle map without a category as a car', () {
    final vehicle = Vehicle.fromMap({
      'id': 'legacy-car',
      'user_id': 'mock_user_default',
      'name': 'Meu carro',
      'brand': 'Honda',
      'model': 'Fit',
      'year_manufacture': null,
      'year_model': 2020,
      'plate': null,
      'current_odometer': 80000,
      'fuel_type': 'FLEX',
      'archived_at': null,
      'created_at': '2025-01-01T00:00:00.000Z',
      'updated_at': '2025-01-01T00:00:00.000Z',
    });

    expect(vehicle.vehicleType, VehicleType.car);
  });

  test('all vehicle categories have stable storage values', () {
    expect(VehicleType.values.map((type) => type.toStorage()), [
      'CAR',
      'MOTORCYCLE',
      'TRUCK',
      'VAN',
      'BUS',
      'OTHER',
    ]);
    for (final type in VehicleType.values) {
      expect(VehicleTypeStorage.fromStorage(type.toStorage()), type);
    }
  });
}
