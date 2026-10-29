# Spec Delta

## Purpose

Permite localizar rapidamente veículos cadastrados e refletir de imediato no detalhe as alterações confirmadas na quilometragem atual.

## ADDED Requirements

### Requirement: Quick and searchable garage lists
O sistema SHALL mostrar cards de acesso rápido e uma lista vertical pesquisável para localizar veículos ativos.

#### Scenario: Search vehicles
- **WHEN** a pessoa digita um termo na busca da lista vertical
- **THEN** o sistema mostra veículos cujo apelido, marca, modelo ou placa corresponde ao termo, sem diferenciar maiúsculas de minúsculas

#### Scenario: Select a vehicle from the vertical list
- **WHEN** a pessoa seleciona um veículo encontrado na lista vertical
- **THEN** o sistema seleciona esse veículo e atualiza o resumo rápido correspondente

#### Scenario: No matching vehicles
- **WHEN** o termo de busca não corresponde a nenhum veículo ativo
- **THEN** o sistema informa que nenhum veículo foi encontrado

### Requirement: Immediate odometer display after maintenance
O sistema SHALL refletir imediatamente nos detalhes a quilometragem atualizada após a pessoa confirmar o uso do odômetro informado em uma manutenção.

#### Scenario: Confirm and save a higher service odometer
- **WHEN** a pessoa confirma a atualização para o odômetro do serviço e o registro é salvo
- **THEN** os detalhes mostram o novo odômetro sem exigir saída e retorno à tela
