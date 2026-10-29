import 'package:flutter/material.dart';

import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_visuals.dart';

class ArchivedVehiclesScreen extends StatefulWidget {
  const ArchivedVehiclesScreen({super.key, required this.vehicleRepository});

  final VehicleRepository vehicleRepository;

  @override
  State<ArchivedVehiclesScreen> createState() => _ArchivedVehiclesScreenState();
}

class _ArchivedVehiclesScreenState extends State<ArchivedVehiclesScreen> {
  late Future<List<Vehicle>> _vehicles = widget.vehicleRepository
      .getArchivedVehicles();

  Future<void> _restore(Vehicle vehicle) async {
    await widget.vehicleRepository.restoreVehicle(
      id: vehicle.id,
      userId: vehicle.userId,
    );
    if (!mounted) return;
    setState(() {
      _vehicles = widget.vehicleRepository.getArchivedVehicles();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${vehicle.name} foi restaurado.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Veículos arquivados')),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os veículos.'),
            );
          }
          final vehicles = snapshot.data ?? const <Vehicle>[];
          if (vehicles.isEmpty) {
            return const Center(child: Text('Nenhum veículo arquivado.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(vehicle.vehicleType.icon)),
                  title: Text(vehicle.name),
                  subtitle: Text(
                    '${vehicle.vehicleType.label} • ${vehicle.brand} ${vehicle.model}',
                  ),
                  trailing: TextButton.icon(
                    onPressed: () => _restore(vehicle),
                    icon: const Icon(Icons.unarchive_outlined),
                    label: const Text('Restaurar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
