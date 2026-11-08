import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../vehicle_management/domain/vehicle.dart';
import '../domain/maintenance_record.dart';

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({
    super.key,
    required this.vehicle,
    this.initialRecord,
  });

  final Vehicle vehicle;
  final MaintenanceRecord? initialRecord;

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.initialRecord?.title ?? '',
  );
  late final _odometerController = TextEditingController(
    text:
        (widget.initialRecord?.odometerAtService ??
                widget.vehicle.currentOdometer)
            .toString(),
  );
  late final _partsController = TextEditingController(
    text: _moneyText(widget.initialRecord?.costPartsCents),
  );
  late final _laborController = TextEditingController(
    text: _moneyText(widget.initialRecord?.costLaborCents),
  );
  late final _totalController = TextEditingController(
    text: _moneyText(widget.initialRecord?.totalCostCents),
  );
  late final _providerController = TextEditingController(
    text: widget.initialRecord?.serviceProvider ?? '',
  );
  late final _notesController = TextEditingController(
    text: widget.initialRecord?.notes ?? '',
  );
  late final _nextOdometerController = TextEditingController(
    text: widget.initialRecord?.nextRecommendedOdometer?.toString() ?? '',
  );
  late DateTime _date = widget.initialRecord?.date ?? DateTime.now();
  DateTime? _nextDate;
  MaintenanceType _type = MaintenanceType.preventive;

  @override
  void initState() {
    super.initState();
    final record = widget.initialRecord;
    if (record != null) {
      _type = record.type;
      _nextDate = record.nextRecommendedDate;
    }
    _partsController.addListener(_updateCalculatedTotal);
    _laborController.addListener(_updateCalculatedTotal);
  }

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _odometerController,
      _partsController,
      _laborController,
      _totalController,
      _providerController,
      _notesController,
      _nextOdometerController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCalculatedTotal() {
    final parts = _parseMoney(_partsController.text);
    final labor = _parseMoney(_laborController.text);
    if (parts != null && labor != null) {
      _totalController.text = _moneyText(parts + labor);
    }
  }

  Future<void> _pickDate({bool recommendation = false}) async {
    final current = recommendation ? (_nextDate ?? _date) : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (recommendation) {
        _nextDate = picked;
      } else {
        _date = picked;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final partsCost = _parseMoney(_partsController.text);
    final laborCost = _parseMoney(_laborController.text);
    final record = MaintenanceRecord(
      id: widget.initialRecord?.id,
      userId: widget.vehicle.userId,
      vehicleId: widget.vehicle.id,
      title: _titleController.text.trim(),
      type: _type,
      date: DateTime(_date.year, _date.month, _date.day),
      odometerAtService: int.tryParse(_odometerController.text),
      costPartsCents: partsCost,
      costLaborCents: laborCost,
      totalCostCents: partsCost != null && laborCost != null
          ? partsCost + laborCost
          : _parseMoney(_totalController.text),
      serviceProvider: _optional(_providerController.text),
      notes: _optional(_notesController.text),
      nextRecommendedDate: _nextDate,
      nextRecommendedOdometer: int.tryParse(_nextOdometerController.text),
      createdAt: widget.initialRecord?.createdAt,
    );
    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRecord != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar manutenção' : 'Nova manutenção'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: _fieldDecoration(
                labelText: 'Título *',
                icon: Icons.build_outlined,
                help: 'Resumo curto do serviço realizado.',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe um título'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<MaintenanceType>(
              isExpanded: true,
              initialValue: _type,
              decoration: _fieldDecoration(
                labelText: 'Tipo *',
                icon: Icons.category_outlined,
                help: 'Classifique como preventiva, corretiva ou revisão.',
              ),
              items: MaintenanceType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_typeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 14),
            Tooltip(
              message: 'Dia em que o serviço foi realizado.',
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Data do serviço: ${_dateText(_date)}'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _fieldDecoration(
                labelText: 'Quilometragem do serviço (km)',
                icon: Icons.speed_outlined,
                help:
                    'Km do veículo quando o serviço foi feito. Pode deixar em branco.',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _partsController,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(
                labelText: 'Custo de peças (R\$)',
                icon: Icons.handyman_outlined,
                help: 'Valor gasto com peças. Informe em reais.',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _laborController,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(
                labelText: 'Mão de obra (R\$)',
                icon: Icons.engineering_outlined,
                help: 'Valor da mão de obra. Informe em reais.',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _totalController,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(
                labelText: 'Custo total (R\$)',
                icon: Icons.payments_outlined,
                help:
                    'Soma das peças e da mão de obra; pode ser informado manualmente.',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _providerController,
              decoration: _fieldDecoration(
                labelText: 'Oficina ou prestador',
                icon: Icons.storefront_outlined,
                help: 'Nome da oficina, mecânico ou prestador do serviço.',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: _fieldDecoration(
                labelText: 'Observações',
                icon: Icons.notes_outlined,
                help:
                    'Detalhes úteis, como peças, marcas, recomendações ou diagnóstico.',
              ),
            ),
            const SizedBox(height: 14),
            Tooltip(
              message: 'Data sugerida para a próxima manutenção.',
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(recommendation: true),
                icon: const Icon(Icons.event_repeat_outlined),
                label: Text(
                  _nextDate == null
                      ? 'Previsão da próxima data'
                      : 'Próxima data: ${_dateText(_nextDate!)}',
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nextOdometerController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _fieldDecoration(
                labelText: 'Previsão de km da próxima revisão',
                icon: Icons.route_outlined,
                help: 'Km estimado para a próxima troca ou revisão.',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: FilledButton(
          onPressed: _save,
          child: Text(isEditing ? 'Salvar alterações' : 'Salvar manutenção'),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String labelText,
  required IconData icon,
  required String help,
}) => InputDecoration(
  labelText: labelText,
  prefixIcon: Icon(icon),
  suffixIcon: Tooltip(
    message: help,
    child: IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
  ),
);

String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

String _dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _typeLabel(MaintenanceType type) => switch (type) {
  MaintenanceType.preventive => 'Preventiva',
  MaintenanceType.corrective => 'Corretiva',
  MaintenanceType.inspection => 'Revisão periódica',
};

int? _parseMoney(String raw) {
  final value = raw.trim().replaceAll(RegExp(r'[^0-9,.-]'), '');
  if (value.isEmpty) return null;
  final normalized = value.contains(',')
      ? value.replaceAll('.', '').replaceFirst(',', '.')
      : value;
  final parsed = double.tryParse(normalized);
  return parsed == null ? null : (parsed * 100).round();
}

String _moneyText(int? cents) => cents == null
    ? ''
    : '${(cents ~/ 100)},${(cents % 100).toString().padLeft(2, '0')}';
