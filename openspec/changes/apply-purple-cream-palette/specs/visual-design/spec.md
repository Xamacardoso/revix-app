# Spec Delta

## Purpose

Define uma identidade visual comum para as telas e materiais de design do Revix com base na paleta de cores escolhida pelo usuário.

## ADDED Requirements

### Requirement: Aplicar a paleta Revix de forma consistente
As telas do aplicativo SHALL usar os tokens `#242038`, `#725AC1`, `#8D86C9`, `#CAC4CE` e `#F7ECE1` para texto principal, ações, destaques, contornos e superfícies, respectivamente.

#### Scenario: Aplicação da paleta no tema
- **WHEN** uma tela é renderizada usando o tema padrão do Revix
- **THEN** o fundo usa o tom creme, as ações principais usam roxo, o texto principal usa carvão e contornos usam o neutro lavanda

#### Scenario: Consistência de materiais de design
- **WHEN** um novo wireframe ou decisão visual é adicionado à documentação
- **THEN** seus exemplos de cor seguem os mesmos tokens definidos na documentação de design
