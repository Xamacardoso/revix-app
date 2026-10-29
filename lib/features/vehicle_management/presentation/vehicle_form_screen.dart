import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/user_context.dart';
import '../domain/vehicle.dart';
import 'brazilian_plate.dart';
import 'vehicle_visuals.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.initialVehicle});

  final Vehicle? initialVehicle;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearManufactureController;
  late final TextEditingController _yearModelController;
  late final TextEditingController _plateController;
  late final TextEditingController _odometerController;
  late FuelType _fuelType;
  late VehicleType _vehicleType;

  bool get _isEditing => widget.initialVehicle != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.initialVehicle;
    _nameController = TextEditingController(text: vehicle?.name ?? '');
    _brandController = TextEditingController(text: vehicle?.brand ?? '');
    _modelController = TextEditingController(text: vehicle?.model ?? '');
    _yearManufactureController = TextEditingController(
      text: vehicle?.yearManufacture?.toString() ?? '',
    );
    _yearModelController = TextEditingController(
      text: vehicle?.yearModel.toString() ?? '',
    );
    _plateController = TextEditingController(text: vehicle?.plate ?? '');
    _odometerController = TextEditingController(
      text: vehicle?.currentOdometer.toString() ?? '',
    );
    _fuelType = vehicle?.fuelType ?? FuelType.flex;
    _vehicleType = vehicle?.vehicleType ?? VehicleType.car;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearManufactureController.dispose();
    _yearModelController.dispose();
    _plateController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.initialVehicle;
    final vehicle = Vehicle(
      id: existing?.id,
      userId: existing?.userId ?? mockUserId,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      yearManufacture: int.tryParse(_yearManufactureController.text),
      yearModel: int.parse(_yearModelController.text),
      plate: _plateController.text.trim().isEmpty
          ? null
          : _plateController.text.trim().toUpperCase(),
      currentOdometer: int.parse(_odometerController.text),
      fuelType: _fuelType,
      vehicleType: _vehicleType,
      archivedAt: existing?.archivedAt,
      createdAt: existing?.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    Navigator.of(context).pop(vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar veículo' : 'Novo veículo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Identificação',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _nameController,
                    icon: Icons.drive_file_rename_outline,
                    help:
                        'Nome curto para identificar este veículo na garagem.',
                    label: 'Apelido',
                    hint: 'Ex.: Meu Civic',
                    validator: _requiredValidator('o apelido'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _brandController,
                    icon: Icons.factory_outlined,
                    help: 'Fabricante do veículo.',
                    label: 'Marca',
                    hint: 'Ex.: Honda',
                    validator: _requiredValidator('a marca'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _modelController,
                    icon: Icons.directions_car_outlined,
                    help: 'Modelo e versão do veículo.',
                    label: 'Modelo',
                    hint: 'Ex.: Civic G10 EXL',
                    validator: _requiredValidator('o modelo'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<VehicleType>(
                    key: const ValueKey('vehicle-type-field'),
                    initialValue: _vehicleType,
                    decoration: _fieldDecoration(
                      label: 'Tipo de veículo',
                      icon: Icons.category_outlined,
                      help:
                          'Escolha carro, motocicleta, caminhão, van, ônibus ou outro.',
                    ),
                    items: VehicleType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _vehicleType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<FuelType>(
                    initialValue: _fuelType,
                    decoration: _fieldDecoration(
                      label: 'Combustível',
                      icon: Icons.local_gas_station_outlined,
                      help: 'Tipo de combustível usado pelo veículo.',
                    ),
                    items: FuelType.values
                        .map(
                          (fuelType) => DropdownMenuItem(
                            value: fuelType,
                            child: Text(_fuelLabel(fuelType)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _fuelType = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Dados do veículo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          controller: _yearManufactureController,
                          icon: Icons.event_outlined,
                          help:
                              'Ano em que o veículo foi fabricado, se souber.',
                          label: 'Ano fabricação',
                          hint: 'Opcional',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: _optionalYearValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          controller: _yearModelController,
                          icon: Icons.calendar_month_outlined,
                          help: 'Ano modelo indicado no documento do veículo.',
                          label: 'Ano modelo *',
                          hint: 'Ex.: 2024',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: _requiredYearValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _plateController,
                    icon: Icons.pin_outlined,
                    help:
                        'Placa nos formatos antigo ou Mercosul. Campo opcional.',
                    label: 'Placa',
                    hint: 'ABC-1234 ou ABC1D23',
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [BrazilianPlateInputFormatter()],
                    validator: (value) {
                      if (!isBrazilianPlateValid(value ?? '')) {
                        return 'Informe uma placa válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _odometerController,
                    icon: Icons.speed_outlined,
                    help:
                        'Quilometragem atual exibida nos cards e usada como referência.',
                    label: 'Quilometragem atual (km) *',
                    hint: 'Ex.: 52.300',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _odometerValidator,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _isEditing ? 'Salvar alterações' : 'Salvar veículo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String help,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _fieldDecoration(
        label: label,
        hintText: hint,
        icon: icon,
        help: help,
      ),
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hintText,
    required IconData icon,
    required String help,
  }) => InputDecoration(
    labelText: label,
    hintText: hintText,
    prefixIcon: Icon(icon),
    suffixIcon: Tooltip(
      message: help,
      child: IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
    ),
  );

  String? Function(String?) _requiredValidator(String fieldName) => (value) {
    if (value == null || value.trim().isEmpty) return 'Informe $fieldName';
    return null;
  };

  String? _requiredYearValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o ano modelo';
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'Use um ano com 4 dígitos';
    return null;
  }

  String? _optionalYearValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'Use um ano com 4 dígitos';
    return null;
  }

  String? _odometerValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a quilometragem';
    final odometer = int.tryParse(value);
    if (odometer == null || odometer < 0) return 'Informe um km válido';
    return null;
  }

  String _fuelLabel(FuelType fuelType) => switch (fuelType) {
    FuelType.gasoline => 'Gasolina',
    FuelType.ethanol => 'Etanol',
    FuelType.flex => 'Flex',
    FuelType.diesel => 'Diesel',
    FuelType.electric => 'Elétrico',
    FuelType.hybrid => 'Híbrido',
  };
}
