# Proposal

## Why

Motoristas precisam de um lugar confiável para acompanhar a manutenção preventiva e corretiva dos veículos, inclusive quando estão sem internet. Hoje o projeto ainda não oferece esse fluxo; estabelecer a capacidade agora define uma base local que poderá receber sincronização e backup em nuvem no futuro.

## What Changes

- Introduzir o gerenciamento de veículos, incluindo cadastro, edição, atualização rápida do odômetro e arquivamento/restauração.
- Introduzir uma capacidade separada para registrar e consultar manutenções e inspeções vinculadas aos veículos, incluindo quilometragem, custos e recomendações futuras.
- Definir uma experiência mobile offline-first, mantendo os dados no aparelho e a interface independente da persistência local.
- Preparar a estrutura de dados e os limites da persistência para futura sincronização e backup, sem incluir serviços de nuvem ou autenticação real nesta entrega.

## Capabilities

### New Capabilities

- `vehicle-management`: cadastro, consulta, edição, atualização rápida do odômetro e arquivamento/restauração dos veículos.
- `vehicle-maintenance`: criação e consulta dos registros de manutenção associados a um veículo, incluindo histórico, filtros, custos e recomendações futuras.

### Modified Capabilities

Nenhuma.

## Impact

- Novo aplicativo mobile em Flutter, com persistência local em SQLite e migrações de banco.
- Novos fluxos de telas para lista de veículos, detalhes, histórico, cadastro/edição de veículos e registros de manutenção.
- Modelo local preparado para múltiplos usuários, usando `mock_user_default` como identidade estática inicial.
- Sincronização, backup em nuvem e autenticação real permanecem fora do escopo desta mudança.
