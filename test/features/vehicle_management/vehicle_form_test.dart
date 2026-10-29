import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revix/features/vehicle_management/presentation/brazilian_plate.dart';
import 'package:revix/features/vehicle_management/presentation/vehicle_form_screen.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';

void main() {
  group('Brazilian plate formatting and validation', () {
    test('formats old plate pattern with a hyphen', () {
      expect(formatBrazilianPlate('abc1234'), 'ABC-1234');
      expect(isBrazilianPlateValid('ABC-1234'), isTrue);
    });

    test('keeps Mercosul plate pattern without a hyphen', () {
      expect(formatBrazilianPlate('abc1d23'), 'ABC1D23');
      expect(isBrazilianPlateValid('ABC1D23'), isTrue);
    });

    test('allows an empty optional plate and rejects invalid values', () {
      expect(isBrazilianPlateValid(''), isTrue);
      expect(isBrazilianPlateValid('AB-123'), isFalse);
      expect(isBrazilianPlateValid('ABC12D3'), isFalse);
    });
  });

  testWidgets('shows inline errors for missing required fields', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: VehicleFormScreen()));
    expect(
      find.byTooltip('Nome curto para identificar este veículo na garagem.'),
      findsOneWidget,
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar veículo'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o apelido'), findsOneWidget);
    expect(find.text('Informe a marca'), findsOneWidget);
    expect(find.text('Informe o modelo'), findsOneWidget);
    expect(find.text('Informe o ano modelo'), findsOneWidget);
    expect(find.text('Informe a quilometragem'), findsOneWidget);
  });

  testWidgets('edits and offers all supported vehicle categories', (
    tester,
  ) async {
    final motorcycle = Vehicle(
      id: 'motorcycle-form',
      name: 'Minha moto',
      brand: 'Honda',
      model: 'CB 500X',
      yearModel: 2023,
      currentOdometer: 12000,
      fuelType: FuelType.gasoline,
      vehicleType: VehicleType.motorcycle,
    );
    Vehicle? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Vehicle>(
                  MaterialPageRoute(
                    builder: (_) =>
                        VehicleFormScreen(initialVehicle: motorcycle),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final typeField = tester.widget<DropdownButtonFormField<VehicleType>>(
      find.byKey(const ValueKey('vehicle-type-field')),
    );
    expect(typeField.initialValue, VehicleType.motorcycle);
    await tester.tap(find.byKey(const ValueKey('vehicle-type-field')));
    await tester.pumpAndSettle();
    expect(find.text('Carro'), findsOneWidget);
    expect(find.text('Motocicleta'), findsWidgets);
    expect(find.text('Caminhão'), findsOneWidget);
    expect(find.text('Van'), findsOneWidget);
    expect(find.text('Ônibus'), findsOneWidget);
    expect(find.text('Outro veículo'), findsOneWidget);
    await tester.tap(find.text('Caminhão'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(result?.vehicleType, VehicleType.truck);
  });
}
