import 'package:flutter/material.dart';

import '../domain/vehicle.dart';

extension VehicleTypePresentation on VehicleType {
  String get label => switch (this) {
    VehicleType.car => 'Carro',
    VehicleType.motorcycle => 'Motocicleta',
    VehicleType.truck => 'Caminhão',
    VehicleType.van => 'Van',
    VehicleType.bus => 'Ônibus',
    VehicleType.other => 'Outro veículo',
  };

  IconData get icon => switch (this) {
    VehicleType.car => Icons.directions_car_outlined,
    VehicleType.motorcycle => Icons.two_wheeler_outlined,
    VehicleType.truck => Icons.local_shipping_outlined,
    VehicleType.van => Icons.airport_shuttle_outlined,
    VehicleType.bus => Icons.directions_bus_outlined,
    VehicleType.other => Icons.commute_outlined,
  };
}
