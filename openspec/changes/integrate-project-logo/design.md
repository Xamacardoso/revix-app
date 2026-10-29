# Design

## Context

O PNG `docs/design/logo-revix.png` já contém o logotipo do projeto e corresponde visualmente à paleta roxa e carvão atual. O asset não está declarado em `pubspec.yaml`; a barra da garagem usa um ícone de carro e texto, e o estado vazio usa outro ícone de carro.

## Goals / Non-Goals

**Goals:**
- Reutilizar o arquivo existente como asset local.
- Mostrar o logo no cabeçalho e no estado vazio com texto alternativo acessível.

**Non-Goals:**
- Redesenhar a marca ou gerar variações de cor.
- Alterar os ícones dos veículos ou os ícones de aplicativos nativos nesta mudança.

## Decisions

- Declarar `docs/design/logo-revix.png` na seção de assets do Flutter para evitar duplicar o arquivo-fonte.
- Usar a imagem com `BoxFit.contain` e texto acessível. O nome Revix continuará como texto no cabeçalho para manter legibilidade em tamanhos pequenos.
- No estado vazio, substituir o ícone de carro pelo logo maior, mantendo a ação existente.

## Risks / Trade-offs

- [Um PNG de proporção quadrada é menos compacto em uma barra horizontal] → usar uma instância pequena e manter o wordmark textual ao lado.
- [Mudanças futuras no arquivo podem quebrar o contrato visual] → manter o arquivo como artefato de design referenciado e cobrir o carregamento do asset em teste.
