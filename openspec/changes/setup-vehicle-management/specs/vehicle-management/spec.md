# Spec Delta

## Purpose

Permite que uma pessoa cadastre e acompanhe os dados dos próprios veículos em um aplicativo mobile que funciona sem conexão.

## ADDED Requirements

### Requirement: Vehicle profile data
O sistema SHALL manter, para cada veículo, um identificador estável, o usuário responsável, apelido, marca, modelo, ano-modelo, odômetro atual, tipo de combustível e timestamps de criação e atualização; ano de fabricação e placa são opcionais. O usuário inicial SHALL ser `mock_user_default`.

#### Scenario: Create a vehicle
- **WHEN** a pessoa salva um veículo com apelido, marca, modelo, ano-modelo e odômetro válidos
- **THEN** o sistema persiste o veículo associado a `mock_user_default`, com identificador estável e timestamps

#### Scenario: Supported fuel types
- **WHEN** a pessoa escolhe o tipo de combustível
- **THEN** o sistema aceita `GASOLINE`, `ETHANOL`, `FLEX`, `DIESEL`, `ELECTRIC` ou `HYBRID`

### Requirement: Vehicle form validation
O sistema SHALL exigir apelido, marca, modelo, ano-modelo e odômetro atual, destacar campos obrigatórios inválidos e aceitar placas nos formatos brasileiro antigo e Mercosul.

#### Scenario: Missing required field
- **WHEN** a pessoa tenta salvar um veículo sem preencher um campo obrigatório
- **THEN** o sistema indica o campo inválido e não salva o veículo

#### Scenario: Brazilian plate formats
- **WHEN** a pessoa informa uma placa nos formatos brasileiro antigo ou Mercosul
- **THEN** o sistema aceita a entrada e aplica a máscara correspondente

### Requirement: Vehicle dashboard
O sistema SHALL mostrar os veículos ativos em cards com apelido, modelo, placa quando disponível e odômetro atual, além de permitir iniciar o cadastro de um novo veículo.

#### Scenario: View vehicle list
- **WHEN** a pessoa abre a tela inicial
- **THEN** o sistema lista os veículos ativos e oferece a ação de cadastrar um novo veículo

### Requirement: Vehicle details and odometer update
O sistema SHALL mostrar os dados do veículo, permitir editar o veículo e atualizar o odômetro atual sem exigir a criação de um registro de manutenção.

#### Scenario: Update odometer without maintenance
- **WHEN** a pessoa informa um novo odômetro válido nos detalhes do veículo
- **THEN** o sistema atualiza o odômetro atual sem criar um registro de manutenção

### Requirement: Vehicle archive and restore
O sistema SHALL arquivar veículos sem apagar os registros de manutenção associados, ocultá-los da lista principal, disponibilizá-los em uma área de arquivados e permitir restaurá-los.

#### Scenario: Archive vehicle
- **WHEN** a pessoa escolhe arquivar um veículo
- **THEN** o veículo deixa a lista principal e permanece acessível na área de arquivados com seus dados preservados

#### Scenario: Restore vehicle
- **WHEN** a pessoa restaura um veículo arquivado
- **THEN** o veículo volta à lista principal com seus dados anteriores

### Requirement: Local offline vehicle management
O sistema SHALL permitir consultar e alterar dados de veículos sem conexão à internet, mantendo esses dados disponíveis após fechar e reabrir o aplicativo.

#### Scenario: Use vehicle management offline
- **WHEN** a pessoa consulta ou altera um veículo sem conexão
- **THEN** o sistema apresenta e persiste os dados localmente sem exigir acesso à rede
