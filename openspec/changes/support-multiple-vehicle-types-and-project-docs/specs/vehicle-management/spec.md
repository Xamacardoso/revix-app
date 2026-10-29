# Spec Delta

## Purpose

Permite cadastrar e reconhecer diferentes tipos de veículos no histórico local de manutenção, sem exigir que o usuário trate todo veículo como carro e sem perder os cadastros existentes.

## ADDED Requirements

### Requirement: Cadastro de diferentes tipos de veículo
O sistema SHALL permitir que o usuário escolha se o veículo é carro, motocicleta, caminhão, van, ônibus ou outro veículo motorizado ao cadastrar ou editar.

#### Scenario: Escolher categoria durante o cadastro
- **WHEN** o usuário inicia o cadastro de um veículo
- **THEN** o formulário apresenta as categorias disponíveis e inicia com carro selecionado

#### Scenario: Salvar e reabrir um veículo de outra categoria
- **WHEN** o usuário salva uma motocicleta, caminhão, van, ônibus ou outro tipo de veículo
- **THEN** o tipo escolhido permanece associado ao veículo após fechar e reabrir o aplicativo

### Requirement: Exibir a categoria do veículo
O sistema SHALL identificar visualmente a categoria selecionada no formulário, na listagem e nos detalhes do veículo.

#### Scenario: Identificar uma motocicleta
- **WHEN** um veículo cadastrado como motocicleta é exibido
- **THEN** a interface apresenta o rótulo e o ícone correspondentes a motocicleta

#### Scenario: Identificar outras categorias
- **WHEN** um veículo cadastrado como caminhão, van, ônibus ou outro é exibido
- **THEN** a interface apresenta o rótulo e o ícone correspondentes à categoria cadastrada

### Requirement: Compatibilidade dos veículos existentes
O sistema SHALL preservar os dados dos veículos já cadastrados e atribuir a categoria carro aos registros que não possuíam tipo.

#### Scenario: Atualizar banco sem tipo de veículo
- **WHEN** o aplicativo abre um banco legado sem a coluna de categoria
- **THEN** a migração preserva os veículos e disponibiliza cada um deles como carro

#### Scenario: Ler um mapa legado sem categoria
- **WHEN** dados legados de veículo são carregados sem o campo de categoria
- **THEN** o veículo é interpretado como carro
