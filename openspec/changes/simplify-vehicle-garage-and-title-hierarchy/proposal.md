# Proposal

## Why

A garagem atual repete os mesmos veículos em uma faixa horizontal e em uma lista simples, e ainda mostra dois títulos para a mesma área. Isso aumenta a rolagem e deixa pouco claro onde tocar para abrir um veículo.

## What Changes

- Substituir as listagens duplicadas por uma única lista vertical de cards pesquisável.
- Abrir os detalhes do veículo ao tocar em qualquer ponto do card.
- Usar branco como fundo principal do aplicativo para aumentar o contraste dos textos.
- Manter somente um título para cada conteúdo e documentar essa regra para as demais telas.

## Capabilities

### New Capabilities

- `vehicle-garage-experience`: apresentação, pesquisa e navegação da lista de veículos.
- `interface-title-hierarchy`: hierarquia de títulos sem repetições para o mesmo conteúdo.

### Modified Capabilities

Nenhuma. O inventário atual não contém especificações principais registradas.

## Impact

- Tela Flutter da garagem e tema compartilhado.
- Documentação de produto e de design da garagem e da paleta.
- Novas especificações OpenSpec para a experiência da garagem e a hierarquia de títulos.
