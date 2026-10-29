# Spec Delta

## Purpose

Estabelece uma hierarquia clara de títulos para que cada área de conteúdo do aplicativo tenha um nome principal fácil de identificar, sem repetição visual equivalente.

## ADDED Requirements

### Requirement: Conteúdo não repete títulos equivalentes
Cada tela ou seção SHALL exibir apenas um título principal para identificar o mesmo conteúdo; títulos adjacentes com o mesmo significado SHALL ser consolidados em um único título.

#### Scenario: Tela com título e cabeçalho de seção equivalentes
- **WHEN** o título da tela e o cabeçalho da seção inicial identificam o mesmo conteúdo
- **THEN** somente um dos dois títulos é exibido como título principal

#### Scenario: Tela possui áreas de conteúdo distintas
- **WHEN** uma tela apresenta áreas com conteúdos diferentes
- **THEN** cada área pode ter seu próprio título descritivo, desde que não repita o título de outra área com o mesmo significado
