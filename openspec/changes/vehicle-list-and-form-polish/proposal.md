# Proposal

## Why

A garagem com cards horizontais não oferece uma forma rápida de localizar um veículo quando a pessoa mantém vários cadastrados. Além disso, as telas de cadastro precisam explicar melhor seus campos, e uma manutenção deve poder ser registrada mesmo quando o odômetro do serviço é desconhecido.

## What Changes

- Manter os cards como listagem rápida e acrescentar abaixo uma lista vertical pesquisável de veículos.
- Atualizar imediatamente o odômetro exibido após confirmar um serviço com quilometragem superior à atual.
- Melhorar os formulários de veículo e manutenção com ícones, dicas contextuais e hierarquia visual mais clara; aplicar tipografia mais moderna sem depender de conexão para carregar fontes.
- Tornar opcional o odômetro no registro de manutenção, preservando o preenchimento inicial com o km atual do veículo.

## Capabilities

### New Capabilities

- `vehicle-management`: localização de veículos pela garagem pesquisável e resposta visual imediata após atualização de quilometragem.
- `vehicle-maintenance`: registro de manutenção sem exigir quilometragem do serviço.
- `form-usability`: orientação visual e ajuda contextual nos formulários de veículo e manutenção.

### Modified Capabilities

Nenhuma capacidade já sincronizada existe em `openspec/specs/`; esta mudança cria os contratos que serão incorporados às capacidades definidas pela mudança de configuração inicial.

## Impact

- `VehicleDashboardScreen`, formulários de veículo e manutenção e detalhe do veículo.
- Modelo `MaintenanceRecord`, esquema/migração SQLite e timeline de manutenção.
- Tema Flutter e testes de formulário, listagem, atualização de odômetro e persistência.
