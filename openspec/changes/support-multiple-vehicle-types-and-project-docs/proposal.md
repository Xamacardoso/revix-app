# Proposal

## Why

O cadastro atual representa qualquer item como carro, embora a manutenção preventiva e corretiva também se aplique a motocicletas, caminhões, vans, ônibus e outros veículos. O projeto também precisa de uma documentação navegável que reúna decisões, requisitos, arquitetura, design e operação sem substituir as especificações OpenSpec.

## What Changes

- Adicionar um tipo de veículo persistido, com opções para carro, motocicleta, caminhão, van, ônibus e outros.
- Atualizar o formulário, cards e detalhes para selecionar e identificar corretamente o tipo, mantendo registros antigos compatíveis como carros.
- Avançar o SQLite com migração que preserve veículos já cadastrados.
- Criar `docs/` com índice, requisitos do produto, decisões de design, wireframe, arquitetura/dados, operação, changelog e espaço documentado para capturas.
- Ligar o README à documentação e explicar que OpenSpec permanece a fonte normativa dos requisitos de comportamento.

## Capabilities

### New Capabilities

- `vehicle-management`: Cadastro e identificação de veículos de vários tipos, com persistência e compatibilidade dos registros existentes.

### Modified Capabilities

Nenhuma. O repositório ainda não possui especificações principais sincronizadas; a capacidade será introduzida neste change e poderá ser sincronizada após a implementação.

## Impact

- Flutter: domínio `Vehicle`, formulário, dashboard e detalhes.
- SQLite: migração para armazenar `vehicle_type` sem alterar os dados já existentes.
- Testes de unidade/widget e de migração.
- README e novos artefatos Markdown em `docs/`.
