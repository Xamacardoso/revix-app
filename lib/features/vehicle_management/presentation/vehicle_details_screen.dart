import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_visuals.dart';
import '../../vehicle_maintenance/data/maintenance_entry_service.dart';
import '../../vehicle_maintenance/data/maintenance_repository.dart';
import '../../vehicle_maintenance/data/sqlite_maintenance_repository.dart';
import '../../vehicle_maintenance/domain/maintenance_record.dart';
import '../../vehicle_maintenance/presentation/maintenance_form_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
    required this.vehicleRepository,
    this.maintenanceSaver,
    this.maintenanceRepository,
  });

  final Vehicle vehicle;
  final VehicleRepository vehicleRepository;
  final MaintenanceRecordSaver? maintenanceSaver;
  final MaintenanceRepository? maintenanceRepository;

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late Vehicle _vehicle = widget.vehicle;
  late final MaintenanceRepository _maintenanceRepository =
      widget.maintenanceRepository ?? SqliteMaintenanceRepository();
  late Future<List<MaintenanceRecord>> _maintenanceRecords =
      _maintenanceRepository.getRecordsForVehicle(
        vehicleId: _vehicle.id,
        userId: _vehicle.userId,
      );
  String _maintenanceFilter = 'Todas';

  Future<void> _editVehicle() async {
    final updatedVehicle = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => VehicleFormScreen(initialVehicle: _vehicle),
      ),
    );
    if (updatedVehicle == null) return;
    await widget.vehicleRepository.saveVehicle(updatedVehicle);
    if (mounted) setState(() => _vehicle = updatedVehicle);
  }

  Future<void> _archiveVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar veículo?'),
        content: const Text(
          'O veículo sairá da garagem, mas seu histórico de manutenção será preservado. Você poderá restaurá-lo depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.vehicleRepository.archiveVehicle(
      id: _vehicle.id,
      userId: _vehicle.userId,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _updateOdometer() async {
    final newOdometer = await showDialog<int>(
      context: context,
      builder: (_) =>
          _OdometerDialog(currentOdometer: _vehicle.currentOdometer),
    );

    if (newOdometer == null) return;
    await widget.vehicleRepository.updateCurrentOdometer(
      id: _vehicle.id,
      userId: _vehicle.userId,
      odometer: newOdometer,
    );
    if (mounted) {
      setState(
        () => _vehicle = _vehicle.copyWith(
          currentOdometer: newOdometer,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  Future<void> _createMaintenance({MaintenanceRecord? initialRecord}) async {
    final record = await Navigator.of(context).push<MaintenanceRecord>(
      MaterialPageRoute(
        builder: (_) => MaintenanceFormScreen(
          vehicle: _vehicle,
          initialRecord: initialRecord,
        ),
      ),
    );
    if (record == null || !mounted) return;
    final service = widget.maintenanceSaver ?? MaintenanceEntryService();
    try {
      await service.save(record);
    } on OdometerUpdateConfirmationRequired catch (request) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Atualizar quilometragem do veículo?'),
          content: Text(
            'O km do serviço (${_formatOdometer(request.service)} km) é superior ao km atual do veículo (${_formatOdometer(request.current)} km). Deseja atualizar o km atual do veículo para este valor?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não, cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Atualizar e salvar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await service.save(record, confirmOdometerUpdate: true);
      if (mounted) {
        setState(() {
          _vehicle = _vehicle.copyWith(
            currentOdometer: request.service,
            updatedAt: DateTime.now().toUtc(),
          );
        });
      }
    }
    if (mounted) {
      setState(() {
        _maintenanceRecords = _maintenanceRepository.getRecordsForVehicle(
          vehicleId: _vehicle.id,
          userId: _vehicle.userId,
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Manutenção salva.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _vehicle;
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.name),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opções do veículo',
            onSelected: (action) {
              if (action == 'edit') _editVehicle();
              if (action == 'archive') _archiveVehicle();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar veículo'),
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.archive_outlined),
                  title: Text('Arquivar veículo'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(
                          vehicle.vehicleType.icon,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.brand} ${vehicle.model}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${vehicle.vehicleType.label} • ${vehicle.plate ?? 'Sem placa cadastrada'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  Text(
                    'Quilometragem atual',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatOdometer(vehicle.currentOdometer),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 7, bottom: 5),
                        child: Text('km'),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _updateOdometer,
                        icon: const Icon(Icons.speed_outlined),
                        label: const Text('Atualizar km'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Dados do veículo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _DetailRow(label: 'Ano modelo', value: '${vehicle.yearModel}'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _DetailRow(
                  label: 'Ano fabricação',
                  value: vehicle.yearManufacture?.toString() ?? 'Não informado',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _DetailRow(
                  label: 'Combustível',
                  value: _fuelLabel(vehicle.fuelType),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Histórico de manutenção',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final filter in ['Todas', 'Preventivas', 'Corretivas'])
                ChoiceChip(
                  label: Text(filter),
                  selected: _maintenanceFilter == filter,
                  onSelected: (_) =>
                      setState(() => _maintenanceFilter = filter),
                ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<MaintenanceRecord>>(
            future: _maintenanceRecords,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Não foi possível carregar o histórico.'),
                  ),
                );
              }
              final allRecords = snapshot.data ?? const <MaintenanceRecord>[];
              final records = allRecords.where((record) {
                if (_maintenanceFilter == 'Preventivas') {
                  return record.type == MaintenanceType.preventive;
                }
                if (_maintenanceFilter == 'Corretivas') {
                  return record.type == MaintenanceType.corrective;
                }
                return true;
              }).toList();
              if (records.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      allRecords.isEmpty
                          ? 'Nenhuma manutenção registrada.'
                          : 'Nenhum registro neste filtro.',
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final record in records)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          _maintenanceIcon(record.type),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          record.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${_maintenanceTypeLabel(record.type)} • ${_dateLabel(record.date)} • ${record.odometerAtService == null ? 'km não informado' : '${_formatOdometer(record.odometerAtService!)} km'}${record.effectiveTotalCostCents == null ? '' : ' • ${_formatMoney(record.effectiveTotalCostCents!)}'}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Editar registro',
                          onPressed: () =>
                              _createMaintenance(initialRecord: record),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createMaintenance,
        icon: const Icon(Icons.add),
        label: const Text('Registrar ação'),
      ),
    );
  }
}

class _OdometerDialog extends StatefulWidget {
  const _OdometerDialog({required this.currentOdometer});

  final int currentOdometer;

  @override
  State<_OdometerDialog> createState() => _OdometerDialogState();
}

class _OdometerDialogState extends State<_OdometerDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentOdometer.toString(),
  );
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null) {
      setState(() => _errorText = 'Informe uma quilometragem válida');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Atualizar quilometragem'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Quilometragem atual (km)',
        suffixText: 'km',
        errorText: _errorText,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Atualizar')),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

String _fuelLabel(FuelType fuelType) => switch (fuelType) {
  FuelType.gasoline => 'Gasolina',
  FuelType.ethanol => 'Etanol',
  FuelType.flex => 'Flex',
  FuelType.diesel => 'Diesel',
  FuelType.electric => 'Elétrico',
  FuelType.hybrid => 'Híbrido',
};

String _formatOdometer(int odometer) => odometer.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => '.',
);

IconData _maintenanceIcon(MaintenanceType type) => switch (type) {
  MaintenanceType.preventive => Icons.build_outlined,
  MaintenanceType.corrective => Icons.handyman_outlined,
  MaintenanceType.inspection => Icons.fact_check_outlined,
};

String _maintenanceTypeLabel(MaintenanceType type) => switch (type) {
  MaintenanceType.preventive => 'Preventiva',
  MaintenanceType.corrective => 'Corretiva',
  MaintenanceType.inspection => 'Revisão periódica',
};

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatMoney(int cents) =>
    'R\$ ${(cents ~/ 100)},${(cents % 100).toString().padLeft(2, '0')}';
