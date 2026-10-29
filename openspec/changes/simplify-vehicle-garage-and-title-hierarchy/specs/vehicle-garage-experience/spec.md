# Spec Delta

## Purpose

Define a experiência de consulta e abertura de veículos na garagem, permitindo localizar cada veículo em uma única lista pesquisável e acessar seus detalhes diretamente.

## ADDED Requirements

### Requirement: Garagem exibe uma única lista vertical de veículos
A garagem SHALL apresentar os veículos ativos em uma única lista vertical de cards grandes e retangulares que ocupem a largura disponível, com uma barra de pesquisa para localizar veículos por apelido, marca, modelo ou placa.

#### Scenario: Consultar veículos sem filtro
- **WHEN** a garagem possui veículos ativos e a pesquisa está vazia
- **THEN** cada veículo é exibido uma única vez em um card na lista vertical

#### Scenario: Filtrar veículos
- **WHEN** o usuário informa texto na barra de pesquisa
- **THEN** a lista exibe somente os veículos cujos campos de apelido, marca, modelo ou placa correspondem ao texto

### Requirement: Card abre os detalhes do veículo
A garagem SHALL abrir os detalhes do veículo associado quando o usuário tocar em qualquer área do card correspondente.

#### Scenario: Abrir detalhes pela garagem
- **WHEN** o usuário toca em um card de veículo
- **THEN** o aplicativo abre a tela de detalhes daquele veículo
