# Spec Delta

## Purpose

Permite que a pessoa registre e consulte separadamente as manutenções e inspeções realizadas em cada veículo, incluindo custos e recomendações futuras.

## ADDED Requirements

### Requirement: Maintenance record data
O sistema SHALL manter registros com identificador estável, usuário responsável, veículo associado, título, tipo (`PREVENTIVE`, `CORRECTIVE` ou `INSPECTION`), data, odômetro no serviço, custos, prestador, observações, recomendações futuras e timestamps. O usuário inicial SHALL ser `mock_user_default`.

#### Scenario: Create a maintenance record
- **WHEN** a pessoa registra uma ação com título, tipo, data e odômetro válidos para um veículo
- **THEN** o sistema persiste o registro associado ao veículo e a `mock_user_default`

#### Scenario: Edit a maintenance record
- **WHEN** a pessoa edita os dados de um registro existente
- **THEN** o sistema atualiza o registro mantendo sua identidade e vínculo com o veículo

### Requirement: Maintenance form defaults
O sistema SHALL iniciar o formulário de manutenção com a data de hoje e o odômetro atual do veículo selecionado.

#### Scenario: Open maintenance form
- **WHEN** a pessoa inicia um novo registro para um veículo
- **THEN** a data vem preenchida com hoje e o odômetro vem preenchido com o valor atual do veículo

### Requirement: Odometer consistency on maintenance entry
O sistema SHALL pedir confirmação explícita para atualizar o odômetro do veículo quando o odômetro de serviço informado for superior ao valor atual.

#### Scenario: Confirm higher service odometer
- **WHEN** a pessoa informa um odômetro de serviço superior ao atual e confirma a atualização
- **THEN** o sistema atualiza o odômetro do veículo e salva o registro de manutenção

#### Scenario: Decline higher service odometer
- **WHEN** a pessoa informa um odômetro de serviço superior ao atual e recusa a atualização
- **THEN** o sistema mantém o odômetro do veículo e não salva o registro de manutenção

### Requirement: Maintenance cost total
O sistema SHALL somar custos de peças e mão de obra quando ambos forem informados e permitir informar o custo total diretamente quando não forem ambos preenchidos.

#### Scenario: Calculate total from parts and labor
- **WHEN** a pessoa informa custos de peças e mão de obra
- **THEN** o sistema preenche o custo total com a soma dos dois valores

#### Scenario: Inform total cost directly
- **WHEN** a pessoa informa o custo total sem preencher ambos os custos de peças e mão de obra
- **THEN** o sistema preserva o custo total informado

### Requirement: Vehicle maintenance timeline
O sistema SHALL disponibilizar os registros do veículo em ordem cronológica reversa e oferecer filtros `Todas`, `Preventivas` e `Corretivas` nos detalhes do veículo.

#### Scenario: Filter maintenance timeline
- **WHEN** a pessoa seleciona `Todas`, `Preventivas` ou `Corretivas`
- **THEN** o sistema mostra os registros correspondentes em ordem cronológica reversa

#### Scenario: Show inspections in all records
- **WHEN** a pessoa seleciona o filtro `Todas`
- **THEN** o sistema inclui registros do tipo `INSPECTION` na timeline

### Requirement: Vehicle maintenance summary
O sistema SHALL disponibilizar um resumo dos gastos ou a manutenção mais recente para o veículo selecionado no dashboard.

#### Scenario: View selected vehicle maintenance summary
- **WHEN** a pessoa seleciona um veículo no dashboard
- **THEN** o sistema apresenta o resumo de gastos ou a manutenção mais recente desse veículo

### Requirement: Local offline maintenance management
O sistema SHALL permitir consultar, criar e editar registros de manutenção sem conexão à internet, mantendo-os disponíveis após fechar e reabrir o aplicativo.

#### Scenario: Use maintenance management offline
- **WHEN** a pessoa consulta ou altera registros sem conexão
- **THEN** o sistema apresenta e persiste os dados localmente sem exigir acesso à rede
