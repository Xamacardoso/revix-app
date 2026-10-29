import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revix/features/vehicle_management/domain/vehicle.dart';
import 'package:revix/features/vehicle_maintenance/domain/maintenance_record.dart';
import 'package:revix/features/vehicle_maintenance/presentation/maintenance_form_screen.dart';

void main() {
  final vehicle = Vehicle(
    id: 'vehicle-1',
    name: 'Meu Civic',
    brand: 'Honda',
    model: 'Civic',
    yearModel: 2020,
    currentOdometer: 52300,
    fuelType: FuelType.flex,
  );

  testWidgets('defaults the date and odometer and returns a valid record', (
    tester,
  ) async {
    MaintenanceRecord? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<MaintenanceRecord>(
                  MaterialPageRoute(
                    builder: (_) => MaintenanceFormScreen(vehicle: vehicle),
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

    expect(
      find.byTooltip('Resumo curto do serviço realizado.'),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Km do veículo quando o serviço foi feito. Pode deixar em branco.',
      ),
      findsOneWidget,
    );
    expect(find.text('Quilometragem do serviço (km)'), findsOneWidget);
    expect(find.text('Data do serviço: ${_today()}'), findsOneWidget);
    final odoField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );
    expect(odoField.controller?.text, '52300');

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título *'),
      'Troca de óleo',
    );
    await tester.tap(find.text('Salvar manutenção'));
    await tester.pumpAndSettle();

    expect(result?.title, 'Troca de óleo');
    expect(result?.odometerAtService, 52300);
    expect(result?.vehicleId, 'vehicle-1');
  });

  testWidgets('requires a title before saving', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MaintenanceFormScreen(vehicle: vehicle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar manutenção'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um título'), findsOneWidget);
    expect(find.text('Informe uma quilometragem válida'), findsNothing);
  });

  testWidgets(
    'saves a maintenance record when service odometer is left blank',
    (tester) async {
      MaintenanceRecord? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await Navigator.of(context)
                    .push<MaintenanceRecord>(
                      MaterialPageRoute(
                        builder: (_) => MaintenanceFormScreen(vehicle: vehicle),
                      ),
                    ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Inspeção visual',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.tap(find.text('Salvar manutenção'));
      await tester.pumpAndSettle();
      expect(result?.title, 'Inspeção visual');
      expect(result?.odometerAtService, isNull);
    },
  );

  testWidgets(
    'calculates the total from parts and labor and accepts direct total',
    (tester) async {
      MaintenanceRecord? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await Navigator.of(context)
                    .push<MaintenanceRecord>(
                      MaterialPageRoute(
                        builder: (_) => MaintenanceFormScreen(vehicle: vehicle),
                      ),
                    ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Revisão');
      await tester.enterText(find.byType(TextFormField).at(2), '12,50');
      await tester.enterText(find.byType(TextFormField).at(3), '7,50');
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(4))
            .controller
            ?.text,
        '20,00',
      );
      await tester.tap(find.text('Salvar manutenção'));
      await tester.pumpAndSettle();
      expect(result?.costPartsCents, 1250);
      expect(result?.costLaborCents, 750);
      expect(result?.totalCostCents, 2000);
      expect(result?.effectiveTotalCostCents, 2000);
    },
  );

  testWidgets(
    'preserves a directly informed total when parts and labor are incomplete',
    (tester) async {
      MaintenanceRecord? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await Navigator.of(context)
                    .push<MaintenanceRecord>(
                      MaterialPageRoute(
                        builder: (_) => MaintenanceFormScreen(vehicle: vehicle),
                      ),
                    ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Reparo');
      await tester.enterText(find.byType(TextFormField).at(4), '25,00');
      await tester.tap(find.text('Salvar manutenção'));
      await tester.pumpAndSettle();
      expect(result?.effectiveTotalCostCents, 2500);
    },
  );
}

String _today() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
}
