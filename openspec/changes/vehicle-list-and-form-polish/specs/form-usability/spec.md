# Spec Delta

## Purpose

Oferece formulários de veículos e manutenções mais claros, com orientação visual consistente e explicações acessíveis para os campos.

## ADDED Requirements

### Requirement: Contextual help in vehicle and maintenance forms
O sistema SHALL mostrar ícones identificáveis nos campos dos formulários e uma ajuda contextual acessível por um ícone de interrogação.

#### Scenario: Read a field explanation
- **WHEN** a pessoa aciona a ajuda de um campo do formulário de veículo ou manutenção
- **THEN** o sistema mostra uma explicação curta sobre o dado esperado e seu uso

### Requirement: Modern readable typography
O sistema SHALL usar tipografia moderna, legível e consistente nas telas principais e formulários sem exigir conexão para carregar a fonte.

#### Scenario: Open the app offline
- **WHEN** a pessoa abre as telas do aplicativo sem conexão à internet
- **THEN** a tipografia configurada permanece disponível e legível
