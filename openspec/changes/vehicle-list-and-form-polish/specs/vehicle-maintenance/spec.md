# Spec Delta

## Purpose

Permite registrar intervenções em veículos mesmo quando a quilometragem do serviço não foi anotada ou não está disponível.

## ADDED Requirements

### Requirement: Optional service odometer
O sistema SHALL permitir salvar um registro de manutenção sem quilometragem do serviço, preservando esse valor como não informado.

#### Scenario: Create a record without service odometer
- **WHEN** a pessoa salva uma manutenção com os demais campos obrigatórios válidos e deixa a quilometragem do serviço vazia
- **THEN** o sistema salva o registro com odômetro não informado e não solicita atualização do odômetro do veículo

#### Scenario: Open the maintenance form
- **WHEN** a pessoa inicia uma manutenção para um veículo com odômetro atual conhecido
- **THEN** o campo de km do serviço começa preenchido com o odômetro atual e pode ser apagado antes de salvar

#### Scenario: View a record without service odometer
- **WHEN** a timeline mostra uma manutenção sem quilometragem informada
- **THEN** a interface indica que o km do serviço não foi informado
