import 'package:flutter/material.dart';

import '../data/sqlite_vehicle_repository.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import '../../../core/theme/revix_palette.dart';
import 'vehicle_details_screen.dart';
import 'vehicle_form_screen.dart';
import 'archived_vehicles_screen.dart';
import 'vehicle_visuals.dart';
import '../../vehicle_maintenance/data/maintenance_repository.dart';
import '../../vehicle_maintenance/data/sqlite_maintenance_repository.dart';

class VehicleDashboardScreen extends StatefulWidget {
  const VehicleDashboardScreen({
    super.key,
    this.vehicleRepository,
    this.maintenanceRepository,
  });

  final VehicleRepository? vehicleRepository;
  final MaintenanceRepository? maintenanceRepository;

  @override
  State<VehicleDashboardScreen> createState() => _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends State<VehicleDashboardScreen> {
  late final VehicleRepository _vehicleRepository =
      widget.vehicleRepository ?? SqliteVehicleRepository();
  late final MaintenanceRepository _maintenanceRepository =
      widget.maintenanceRepository ?? SqliteMaintenanceRepository();

  List<Vehicle> _vehicles = [];
  String _searchQuery = '';
  Object? _loadError;
  bool _isLoading = true;

  List<Vehicle> get _matchingVehicles {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _vehicles;
    return _vehicles
        .where((vehicle) {
          return [
            vehicle.name,
            vehicle.brand,
            vehicle.model,
            vehicle.plate ?? '',
          ].any((value) => value.toLowerCase().contains(query));
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final vehicles = await _vehicleRepository.getActiveVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _createVehicle() async {
    final vehicle = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
    );
    if (vehicle == null) return;
    await _vehicleRepository.saveVehicle(vehicle);
    await _loadVehicles();
  }

  Future<void> _openDetails(Vehicle vehicle) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => VehicleDetailsScreen(
          vehicle: vehicle,
          vehicleRepository: _vehicleRepository,
          maintenanceRepository: _maintenanceRepository,
        ),
      ),
    );
    if (mounted) await _loadVehicles();
  }

  Future<void> _openArchivedVehicles() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            ArchivedVehiclesScreen(vehicleRepository: _vehicleRepository),
      ),
    );
    if (mounted) await _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'docs/design/logo-revix.png',
              key: const Key('revix-header-logo'),
              width: 42,
              height: 42,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 10),
            const Text('Revix', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openArchivedVehicles,
            tooltip: 'Veículos arquivados',
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _ErrorState(onRetry: _loadVehicles)
          : _vehicles.isEmpty
          ? _EmptyState(onAddVehicle: _createVehicle)
          : _buildVehicleList(context),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Sua garagem',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _createVehicle,
              icon: const Icon(Icons.add),
              label: const Text('Novo veículo'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Buscar por apelido, marca, modelo ou placa',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        if (_matchingVehicles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              _searchQuery.trim().isEmpty
                  ? 'Nenhum veículo disponível.'
                  : 'Nenhum veículo encontrado.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ..._matchingVehicles.map((vehicle) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _VehicleCard(
                key: Key('vehicle-card-${vehicle.id}'),
                vehicle: vehicle,
                onTap: () => _openDetails(vehicle),
              ),
            );
          }),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({super.key, required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Material(
        color: RevixPalette.ink,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(vehicle.vehicleType.icon, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.vehicleType.label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (vehicle.plate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle.plate!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  vehicle.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.speed_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${_formatOdometer(vehicle.currentOdometer)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward, color: Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'docs/design/logo-revix.png',
              key: const Key('revix-empty-logo'),
              width: 144,
              height: 144,
              fit: BoxFit.contain,
              semanticLabel: 'Logotipo do Revix',
            ),
            const SizedBox(height: 20),
            Text(
              'Sua garagem está vazia',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre seu primeiro veículo para acompanhar revisões e manutenções.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAddVehicle,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar primeiro veículo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text('Não foi possível carregar seus veículos.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatOdometer(int odometer) => odometer.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => '.',
);
