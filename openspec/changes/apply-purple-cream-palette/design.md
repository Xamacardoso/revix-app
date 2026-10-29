# Design

## Context

O tema Material 3 e alguns componentes ainda usam verdes hardcoded. A paleta aprovada contém carvão `#242038`, roxo `#725AC1`, lilás `#8D86C9`, neutro lavanda `#CAC4CE` e creme `#F7ECE1`.

## Goals / Non-Goals

**Goals:**
- Expor tokens de cor reutilizáveis e aplicá-los ao tema global e componentes que fixam cores.
- Documentar papel e uso dos cinco tons para futuros designs.

**Non-Goals:**
- Redesenhar layout, navegação, tipografia ou ícones.
- Alterar fluxos de negócio ou adicionar tema escuro.

## Decisions

- Centralizar os cinco valores em uma classe de paleta do core e configurar o ColorScheme Material 3 a partir deles.
- Usar o roxo como ação principal, o carvão como texto forte, o creme em fundo/superfície, o neutro lavanda em contornos e o lilás em acentos com texto de alto contraste.
- Manter cores semânticas necessárias para erro/sucesso e branco em texto sobre cartões roxos quando exigido por contraste; não usar esses casos para substituir tokens de marca.
- Substituir valores verdes hardcoded de telas por cores do tema ou tokens da paleta.

## Risks / Trade-offs

- [Texto lilás sobre creme pode ter contraste insuficiente] → usar carvão para textos e reservar lilás para ícones, marcas e superfícies com contraste adequado.
- [Componentes Material podem continuar exibindo cores geradas pelo seed] → fixar os principais papéis no ColorScheme e verificar o tema em teste.
