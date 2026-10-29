# Spec Delta

## Purpose

Define a apresentação consistente do logotipo Revix como parte da identidade visual local do aplicativo.

## ADDED Requirements

### Requirement: Exibir o logotipo do projeto
O aplicativo SHALL carregar o logotipo Revix como asset local e apresentá-lo na garagem, mantendo a identificação acessível.

#### Scenario: Barra superior da garagem
- **WHEN** a tela principal da garagem é exibida
- **THEN** o cabeçalho apresenta o logotipo Revix sem depender de conexão de rede

#### Scenario: Garagem vazia
- **WHEN** ainda não há veículos cadastrados
- **THEN** o estado vazio apresenta o logotipo junto à ação para cadastrar o primeiro veículo
