# Proposal

## Why

O tema atual usa verdes que não correspondem à identidade visual que o usuário escolheu. Centralizar a nova paleta evita variações entre telas e deixa os próximos designs com tokens de cor explícitos.

## What Changes

- Adotar `#242038`, `#725AC1`, `#8D86C9`, `#CAC4CE` e `#F7ECE1` como tokens visuais do aplicativo.
- Atualizar tema Material 3, superfícies, bordas, seleção de veículo e textos secundários para usar os tokens.
- Registrar paleta, funções, exemplos e regras de aplicação em `docs/design/` e atualizar as decisões de interface.

## Capabilities

### New Capabilities

- `visual-design`: Tokens de cor compartilhados e direção visual consistente para as telas do Revix.

### Modified Capabilities

Nenhuma. O repositório não possui especificações principais sincronizadas.

## Impact

- Tema Flutter em `lib/main.dart` e componentes de gerenciamento de veículos.
- Testes de tema e apresentação.
- `docs/product-design.md` e novos artefatos em `docs/design/`.
