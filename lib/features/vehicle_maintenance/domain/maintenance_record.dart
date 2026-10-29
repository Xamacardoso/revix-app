import 'package:uuid/uuid.dart';

import '../../../core/user_context.dart';

enum MaintenanceType { preventive, corrective, inspection }

extension MaintenanceTypeStorage on MaintenanceType {
  String toStorage() => name.toUpperCase();

  static MaintenanceType fromStorage(String value) =>
      MaintenanceType.values.firstWhere(
        (type) => type.toStorage() == value,
        orElse: () => throw FormatException('Unknown maintenance type: $value'),
      );
}

class MaintenanceRecord {
  MaintenanceRecord({
    String? id,
    this.userId = mockUserId,
    required this.vehicleId,
    required this.title,
    required this.type,
    required this.date,
    this.odometerAtService,
    this.costPartsCents,
    this.costLaborCents,
    this.totalCostCents,
    this.serviceProvider,
    this.notes,
    this.nextRecommendedDate,
    this.nextRecommendedOdometer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc();

  static final Uuid _uuid = Uuid();

  final String id;
  final String userId;
  final String vehicleId;
  final String title;
  final MaintenanceType type;
  final DateTime date;
  final int? odometerAtService;
  final int? costPartsCents;
  final int? costLaborCents;
  final int? totalCostCents;
  final String? serviceProvider;
  final String? notes;
  final DateTime? nextRecommendedDate;
  final int? nextRecommendedOdometer;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get effectiveTotalCostCents {
    if (costPartsCents != null && costLaborCents != null) {
      return costPartsCents! + costLaborCents!;
    }
    return totalCostCents;
  }

  factory MaintenanceRecord.fromMap(Map<String, Object?> map) {
    return MaintenanceRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      vehicleId: map['vehicle_id'] as String,
      title: map['title'] as String,
      type: MaintenanceTypeStorage.fromStorage(map['type'] as String),
      date: DateTime.parse(map['date'] as String),
      odometerAtService: map['odometer_at_service'] as int?,
      costPartsCents: map['cost_parts'] as int?,
      costLaborCents: map['cost_labor'] as int?,
      totalCostCents: map['total_cost'] as int?,
      serviceProvider: map['service_provider'] as String?,
      notes: map['notes'] as String?,
      nextRecommendedDate: _dateFromMap(map['next_recommended_date']),
      nextRecommendedOdometer: map['next_recommended_odometer'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': userId,
    'vehicle_id': vehicleId,
    'title': title,
    'type': type.toStorage(),
    'date': _dateOnly(date),
    'odometer_at_service': odometerAtService,
    'cost_parts': costPartsCents,
    'cost_labor': costLaborCents,
    'total_cost': effectiveTotalCostCents,
    'service_provider': serviceProvider,
    'notes': notes,
    'next_recommended_date': nextRecommendedDate == null
        ? null
        : _dateOnly(nextRecommendedDate!),
    'next_recommended_odometer': nextRecommendedOdometer,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime? _dateFromMap(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
