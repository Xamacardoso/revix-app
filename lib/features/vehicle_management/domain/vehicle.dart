import 'package:uuid/uuid.dart';

import '../../../core/user_context.dart';

enum FuelType { gasoline, ethanol, flex, diesel, electric, hybrid }

enum VehicleType { car, motorcycle, truck, van, bus, other }

extension VehicleTypeStorage on VehicleType {
  String toStorage() => name.toUpperCase();

  static VehicleType fromStorage(String value) => VehicleType.values.firstWhere(
    (type) => type.toStorage() == value,
    orElse: () => throw FormatException('Unknown vehicle type: $value'),
  );
}

extension FuelTypeStorage on FuelType {
  String toStorage() => name.toUpperCase();

  static FuelType fromStorage(String value) => FuelType.values.firstWhere(
    (fuelType) => fuelType.toStorage() == value,
    orElse: () => throw FormatException('Unknown fuel type: $value'),
  );
}

class Vehicle {
  Vehicle({
    String? id,
    this.userId = mockUserId,
    required this.name,
    required this.brand,
    required this.model,
    this.yearManufacture,
    required this.yearModel,
    this.plate,
    required this.currentOdometer,
    required this.fuelType,
    this.vehicleType = VehicleType.car,
    this.archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc();

  static final Uuid _uuid = Uuid();

  final String id;
  final String userId;
  final String name;
  final String brand;
  final String model;
  final int? yearManufacture;
  final int yearModel;
  final String? plate;
  final int currentOdometer;
  final FuelType fuelType;
  final VehicleType vehicleType;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle copyWith({
    int? currentOdometer,
    VehicleType? vehicleType,
    DateTime? updatedAt,
  }) => Vehicle(
    id: id,
    userId: userId,
    name: name,
    brand: brand,
    model: model,
    yearManufacture: yearManufacture,
    yearModel: yearModel,
    plate: plate,
    currentOdometer: currentOdometer ?? this.currentOdometer,
    fuelType: fuelType,
    vehicleType: vehicleType ?? this.vehicleType,
    archivedAt: archivedAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Vehicle.fromMap(Map<String, Object?> map) {
    return Vehicle(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      yearManufacture: map['year_manufacture'] as int?,
      yearModel: map['year_model'] as int,
      plate: map['plate'] as String?,
      currentOdometer: map['current_odometer'] as int,
      fuelType: FuelTypeStorage.fromStorage(map['fuel_type'] as String),
      vehicleType: VehicleTypeStorage.fromStorage(
        map['vehicle_type'] as String? ?? 'CAR',
      ),
      archivedAt: _dateTimeFromMap(map['archived_at']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'brand': brand,
    'model': model,
    'year_manufacture': yearManufacture,
    'year_model': yearModel,
    'plate': plate,
    'current_odometer': currentOdometer,
    'fuel_type': fuelType.toStorage(),
    'vehicle_type': vehicleType.toStorage(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}

DateTime? _dateTimeFromMap(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
